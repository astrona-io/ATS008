# Granting Extra Permissions Safely

A policy can be perfectly valid and still do nothing, because the crew that must carry it out has no clearance card for the job. In this part you watch that happen with a `generate` rule, then fix it with a new stamped ClusterRole. You also learn why you never edit the cards Kyverno shipped.

## Why a valid policy can still fail

A `generate` rule tells the background controller to build an object when something happens, for example a new namespace. The policy can be accepted without any error. If the background controller's service account may not create the target kind, the object never appears.

Kyverno's chart gives the background controller a default list of kinds it may create, such as `ResourceQuota`, `NetworkPolicy`, `Role` and `RoleBinding`. The list is the chart value `backgroundController.rbac.coreClusterRole.extraResources`. Your playground empties that list so you can see the failure. When a rule targets a kind that is not on the list, the same failure happens on a normal install.

<!-- astrona:playground:renew -->

### See it in your playground

Create a namespace. The rule `generate-default-quota` should build a `ResourceQuota` named `default-quota` inside it:

```sh
kubectl create namespace harbor
kubectl get resourcequota -n harbor
kubectl get updaterequest -A
```

Look for an empty `ResourceQuota` list. An `UpdateRequest` is a work order waiting in the construction crew's queue. Look for one that did not finish, and for a "forbidden" message about `resourcequotas` in `kubectl get events -n harbor` or in `kubectl describe updaterequest -n kyverno`.

## The fix: a new stamped card

Kyverno's rule is plain: do not change the default roles, add new ones. The chart's own ClusterRoles are written again on every `helm upgrade`, so an edit to one is wiped out silently and the problem comes back with no warning.

Instead, write a new ClusterRole that carries the stamp for the crew that needs it. Save this as `clusterrole-kyverno-generate-resourcequota.yaml`:

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

The label names the crew (`background`). `apiGroups: [""]` means the core group, where `ResourceQuota` lives. For a kind in another group, such as `NetworkPolicy`, the group is `networking.k8s.io`. The verbs are what the rule needs: it reads the target, creates it and, because of `synchronize: true`, updates it.

Apply it:

```sh
kubectl apply -f clusterrole-kyverno-generate-resourcequota.yaml
```

Kubernetes folds the new rules into the background controller's master card within moments. There is no restart and no `helm upgrade`. If you delete the card later, the permission goes away just as cleanly.

### Prove it with the clearance office

Ask again, as the background controller:

```sh
kubectl auth can-i create resourcequotas --as=system:serviceaccount:kyverno:kyverno-background-controller
```

Look for `yes`. This is a faster test than waiting for a rule to run. To see everything a service account may do, add `--list` to the command. Then create a second namespace and look for its quota:

```sh
kubectl create namespace dock
kubectl get resourcequota default-quota -n dock
```

The `ResourceQuota` appears in `dock`. It does not appear in `harbor`, because the rule fired for that namespace before the permission existed. A rule that already failed is not replayed for the old namespace by this change.

## Your mission: ClusterRole Aggregation Lab

You can now find out why a `generate` rule builds nothing and grant the background controller the missing permission with a new, stamped ClusterRole. The mission asks you to do this on a fresh cluster, for `ResourceQuota` objects in the namespaces `carts` and `checkout-svc`, without touching any ClusterRole that Kyverno shipped.

Pause the playground first, so the lab has the memory it needs:

```sh
astrona stop ats-008-playground-040-01
```

Start the lab, then grade it when you are done:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS008.git -c sections/section-040/module-01/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS008.git -c sections/section-040/module-01/labs/lab-01
```

When you are done, remove the lab and start the playground again:

```sh
astrona destroy ats-008-lab-007
astrona start ats-008-playground-040-01
```

## Common pitfalls

> [!WARNING]
> - **Editing a shipped card.** `kubectl edit clusterrole kyverno:background-controller:core` seems to work, until the next `helm upgrade` writes the chart's version back. Add a new card with the stamp.
> - **Using the wrong API group.** `networkpolicies` needs `networking.k8s.io`. With `apiGroups: [""]` the rule matches nothing and `can-i` keeps answering `no`.
> - **Forgetting the stamp.** A ClusterRole without the `rbac.kyverno.io/aggregate-to-background-controller: "true"` label is never collected. The card exists and does nothing.
> - **Waiting for the old namespace to be repaired.** A rule that failed once is not replayed. Create a new namespace to test the fix.
