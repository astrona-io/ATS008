# Part 2 — Granting Extra Permissions Safely

> Prerequisite: [Part 1 — ServiceAccounts, Aggregated ClusterRoles & Built-in View Access](./course-01-serviceaccounts-and-aggregated-clusterroles.md). Next: [Section 050 — High Availability Installations](../../section-050/module-01/course.md).

## Why a valid policy can still fail

A `generate` rule tells Kyverno's background controller to create a resource in response to some trigger — a new Namespace, say. The *policy* can be perfectly valid YAML, applied without error, and still do nothing, because the background controller's ServiceAccount doesn't have `create` (or `update`, for `synchronize: true`) permission on the target resource kind.

This is not a Kyverno bug — it's the aggregated-RBAC model from Part 1 working as designed. Kyverno ships default permissions for the resource kinds its own bundled example policies commonly touch; the moment your `generate` rule targets something else, you need to grant that permission yourself.

## The correct fix: a new, labeled ClusterRole

Kyverno's own guidance is explicit: **default roles should not be modified — new roles should be used to extend them.** The reason is durability: every one of Kyverno's shipped ClusterRoles is reapplied verbatim on every `helm upgrade`. A hand-edit to a shipped role is silently overwritten the next time you upgrade, and the permission gap reappears with no warning.

Instead, create a standalone `ClusterRole` carrying the aggregation label for the controller that needs it:

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

Apply this and Kubernetes' aggregation mechanism folds its `rules` into the background controller's effective top-level ClusterRole immediately — no restart, no Helm upgrade, no touching anything Kyverno shipped. Delete it later and the permission disappears just as cleanly.

> [!TIP]
> **Try it — confirm the fix landed**
>
> ```sh
> kubectl auth can-i create resourcequotas \
>   --as=system:serviceaccount:kyverno:kyverno-background-controller
> ```
>
> `yes` confirms the aggregated ClusterRole is in effect for that ServiceAccount's identity — a faster check than re-triggering the `generate` rule and watching for errors.

## Reference

- `kubectl explain clusterrole.rules` — the live schema for RBAC rule entries (`apiGroups`, `resources`, `verbs`).
- `kubectl auth can-i --as=<serviceaccount> --list` — enumerate everything a given ServiceAccount identity can currently do, useful when diagnosing which permission is actually missing.

> [!WARNING]
> **Common pitfall**
>
> Editing one of Kyverno's shipped `...-core` ClusterRoles directly (`kubectl edit clusterrole kyverno:background-controller:core` or similar) because it's the fastest thing that seems to work. It does work — until the next `helm upgrade` reapplies the chart's version of that role and quietly reverts your edit. Always add a new, separately-named ClusterRole instead.
