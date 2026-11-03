# Solution Walkthrough

You will give the cleanup crew one new clearance card, write a salvage schedule that uses it, and watch the expired ConfigMaps disappear. No ClusterRole that Kyverno shipped is touched.

| Goal | Where it lives | Command or file |
| --- | --- | --- |
| Let the cleanup controller delete ConfigMaps | A new ClusterRole with `rbac.kyverno.io/aggregate-to-cleanup-controller: "true"` | `kubectl apply -f` a YAML file |
| Check the permission without waiting | The clearance office | `kubectl auth can-i ... --as=system:serviceaccount:kyverno:kyverno-cleanup-controller` |
| Remove objects on a schedule | A `ClusterCleanupPolicy` | `kubectl apply -f` a YAML file |

## The feedback loop

Grading runs from the terminal where you typed `astrona run`:

```bash
astrona submit --git ssh://git@github.com/astrona-io/ATS008.git -c sections/section-040/module-02/labs/lab-01
```

The checks are `cleanup-clusterrole`, `cleanup-permission`, `cleanup-policy` and `cleanup-effect`. All four start red, and the grader stops at the first one that fails. Run it after every step.

---

## Step 1: Look at the starting state

```sh
kubectl get configmap -n scrap --show-labels
kubectl auth can-i delete configmaps -n scrap --as=system:serviceaccount:kyverno:kyverno-cleanup-controller
```

You see the three ConfigMaps with their labels. The answer to the second command is `no`. No check turns green in this step.

---

## Step 2: Create the labelled ClusterRole

Save this as `clusterrole-kyverno-cleanup-configmaps.yaml`:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: kyverno-cleanup-configmaps
  labels:
    rbac.kyverno.io/aggregate-to-cleanup-controller: "true"
rules:
  - apiGroups: [""]
    resources: ["configmaps"]
    verbs: ["get", "list", "delete"]
```

- `labels` is the stamp for the cleanup crew.
- `apiGroups: [""]` is the core group, where `ConfigMap` lives.
- `verbs` lets the crew find the objects and delete them. It lists `configmaps` only.

Apply it:

```sh
kubectl apply -f clusterrole-kyverno-cleanup-configmaps.yaml
```

**Run the check.** `cleanup-clusterrole` now passes.

---

## Step 3: Prove the permission

```sh
kubectl auth can-i delete configmaps -n scrap --as=system:serviceaccount:kyverno:kyverno-cleanup-controller
kubectl auth can-i delete secrets -n scrap --as=system:serviceaccount:kyverno:kyverno-cleanup-controller
```

The first answer is `yes` (wait a few seconds and ask again if it says `no`). The second is `no`. **Run the check.** `cleanup-permission` now passes.

---

## Step 4: Create the cleanup policy

Save this as `clustercleanuppolicy-purge-expired-notes.yaml`:

```yaml
apiVersion: kyverno.io/v2
kind: ClusterCleanupPolicy
metadata:
  name: purge-expired-notes
spec:
  schedule: "* * * * *"
  match:
    any:
      - resources:
          kinds:
            - ConfigMap
          namespaces:
            - scrap
          selector:
            matchLabels:
              expired: "true"
```

- `schedule` is a cron schedule: the five stars mean once every minute.
- `match` picks ConfigMaps in `scrap` with the label `expired: "true"`. `keep-note` has `expired: "false"` and is not picked.

Apply it:

```sh
kubectl apply -f clustercleanuppolicy-purge-expired-notes.yaml
```

Kyverno 1.19 may print a warning that this API version is deprecated. The policy still works. **Run the check.** `cleanup-policy` now passes.

---

## Step 5: Wait for the salvage run

```sh
kubectl get configmap -n scrap
```

Run it again every half minute. Within about two minutes `old-note-1` and `old-note-2` are gone and `keep-note` stays. **Run the check.** `cleanup-effect` now passes.

---

## Step 6: Submit

```bash
astrona submit --git ssh://git@github.com/astrona-io/ATS008.git -c sections/section-040/module-02/labs/lab-01
```

## If a check stays red

- **`cleanup-clusterrole` fails: no ClusterRole with the label.** The label must be `rbac.kyverno.io/aggregate-to-cleanup-controller` with the value `"true"`. A label for another controller does nothing here.
- **`cleanup-permission` fails: may delete secrets or pods.** You granted too much. Keep `resources: ["configmaps"]` only.
- **`cleanup-policy` fails: Kyverno refused the policy.** Read the error message. If it names the cleanup controller and a missing permission, apply the ClusterRole first and wait a few seconds.
- **`cleanup-effect` fails: the notes stay.** Check that the schedule has five fields, that the namespace is `scrap` and that the label value is the string `"true"` with quotes. Then wait and run it again.
- **`cleanup-effect` fails: `keep-note` is gone.** The `match` is too wide. Add the label selector and apply the policy again.
