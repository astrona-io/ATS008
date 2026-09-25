# Part 1 — ServiceAccounts, Aggregated ClusterRoles & Built-in View Access

> Prerequisite: [Landing page](./course.md). Next: [Part 2 — Granting Extra Permissions Safely](./course-02-granting-extra-permissions-safely.md).

## Four controllers, four identities

Kyverno is not one process — it is four independent controllers (admission, background, reports, cleanup), and each runs under its own Kubernetes ServiceAccount, all in the `kyverno` namespace:

| Controller | ServiceAccount |
| --- | --- |
| Admission | `kyverno-admission-controller` |
| Background | `kyverno-background-controller` |
| Reports | `kyverno-reports-controller` |
| Cleanup | `kyverno-cleanup-controller` |

Splitting identities this way means a compromise or misconfiguration of one controller doesn't automatically hand over the permissions of the other three. The admission controller, for instance, only ever needs to read the resource it's currently evaluating — it has no business holding the `create`/`update` permissions the background controller needs for `generate` rules.

> [!TIP]
> **Try it — see the ServiceAccounts and their bound ClusterRoles**
>
> ```sh
> kubectl get sa -n kyverno
> kubectl get clusterrole | grep kyverno
> kubectl get clusterrolebinding | grep kyverno
> ```
>
> Each ServiceAccount is bound (via a `ClusterRoleBinding`) to a top-level, per-controller `ClusterRole` — and that role's actual permission list is where aggregation comes in.

## Aggregation: how the top-level role is assembled

Kubernetes ClusterRoles support **aggregation**: a ClusterRole can declare an `aggregationRule` with a label selector, and Kubernetes automatically unions the `rules` of every other ClusterRole matching that selector into it — live, with no controller of your own required.

Kyverno uses this directly. Each controller's top-level ClusterRole aggregates a set of "-core" ClusterRoles Kyverno ships, using a dedicated label per controller:

```
rbac.kyverno.io/aggregate-to-admission-controller: "true"
rbac.kyverno.io/aggregate-to-background-controller: "true"
rbac.kyverno.io/aggregate-to-reports-controller: "true"
rbac.kyverno.io/aggregate-to-cleanup-controller: "true"
```

Any ClusterRole carrying the right label — whether it shipped with Kyverno or you wrote it yourself — is automatically folded into that controller's effective permissions. This is the mechanism Part 2 builds on to grant extra permissions safely.

## Built-in `view` access

The admission, background, and reports controllers are additionally bound to Kubernetes' own built-in `view` ClusterRole, giving them broad read access (`get`/`list`/`watch`) across most namespaced resource kinds. This is what lets a `match`/`context` block or a background scan inspect resources Kyverno wasn't specifically granted access to one-by-one. The Helm value `admissionController.rbac.viewRoleName: view` controls which built-in role name is bound, in case a cluster has replaced or renamed it.

> [!WARNING]
> **Common pitfall**
>
> Assuming Kyverno's controllers run with something close to `cluster-admin` because of how much they *can* touch. They don't — read access comes from the `view` binding, and write access (`create`/`update`/`delete`) is deliberately narrow and aggregation-based, scoped to exactly what each controller's shipped `-core` roles (plus anything you've explicitly aggregated in) grant.

## Reference

- `kubectl explain clusterrole.aggregationRule` — the live schema for ClusterRole aggregation.
- Kubernetes RBAC documentation — "Aggregated ClusterRoles," the general mechanism Kyverno builds on.
