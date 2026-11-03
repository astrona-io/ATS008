# Solution Walkthrough

You will look at a generate rule that builds nothing, add one new ClusterRole with the right label, and prove the next namespace gets its quota. You do not touch any ClusterRole that Kyverno shipped.

| Goal | Where it lives | Command or file |
| --- | --- | --- |
| Give the background controller a permission | A new ClusterRole with the aggregation label | `kubectl apply -f` a YAML file |
| Check the permission without waiting | The clearance office | `kubectl auth can-i ... --as=system:serviceaccount:kyverno:kyverno-background-controller` |
| See the live effect | A new namespace | `kubectl get resourcequota -n <namespace>` |

## The feedback loop

Grading runs from the terminal where you typed `astrona run`:

```bash
astrona submit --git ssh://git@github.com/astrona-io/ATS008.git -c sections/section-040/module-01/labs/lab-01
```

The checks are `clusterrole-exists` (the role exists with the label and the `resourcequotas` rule), `shipped-roles-untouched` (the chart's own background role has no `resourcequotas` rule of its own), `permission-live` (`can-i create resourcequotas` is `yes` for the background controller) and `quota-generated` (`default-quota` exists in `checkout-svc`). All four start red, and the grader stops at the first one that fails. Run the command now, then again after every step.

---

## Step 1: Look at the starting state

```sh
kubectl create namespace carts
kubectl get resourcequota -n carts
kubectl get updaterequest -A
```

No `default-quota` exists in `carts`. Look for an `UpdateRequest` that did not finish, or a "forbidden" message about `resourcequotas` in `kubectl get events -n carts`. No check turns green in this step.

---

## Step 2: Create the labelled ClusterRole

Save this as `clusterrole-kyverno-generate-resourcequota.yaml`:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: kyverno-generate-resourcequota
  labels:
    rbac.kyverno.io/aggregate-to-background-controller: "true"
rules:
  - apiGroups: [""]
    resources: ["resourcequotas"]
    verbs: ["get", "list", "watch", "create", "update"]
```

- `labels` is the stamp. It makes the background controller's master card collect this card.
- `apiGroups: [""]` is the core group, where `ResourceQuota` lives.
- `verbs` are the actions the rule needs.

Apply it:

```sh
kubectl apply -f clusterrole-kyverno-generate-resourcequota.yaml
```

**Run the check.** `clusterrole-exists` and `shipped-roles-untouched` now pass.

---

## Step 3: Prove the permission

```sh
kubectl auth can-i create resourcequotas --as=system:serviceaccount:kyverno:kyverno-background-controller
```

Look for `yes`. If it says `no`, wait a few seconds and ask again. **Run the check.** `permission-live` now passes.

---

## Step 4: Create the second namespace

```sh
kubectl create namespace checkout-svc
kubectl get resourcequota default-quota -n checkout-svc
```

The quota appears within a few seconds. **Run the check.** `quota-generated` now passes.

---

## Step 5: Submit

```bash
astrona submit --git ssh://git@github.com/astrona-io/ATS008.git -c sections/section-040/module-01/labs/lab-01
```

## If a check stays red

- **`clusterrole-exists` fails: missing label.** The label must be exactly `rbac.kyverno.io/aggregate-to-background-controller` with the value `"true"`.
- **`shipped-roles-untouched` fails.** You edited `kyverno:background-controller:core`. Remove your change and use the new ClusterRole only.
- **`permission-live` fails.** The rule is in the wrong API group, or the label names another controller.
- **`quota-generated` fails.** Wait up to a minute and run `kubectl get updaterequest -A`. The old namespace `carts` is not repaired. Check `checkout-svc`.
