# Question

Solve this question on: `terminal`

## Scenario

Kyverno is installed with Helm in the `kyverno` namespace. The `ClusterPolicy` `generate-default-quota` should create a `ResourceQuota` named `default-quota` in every new namespace. New namespaces are not getting one. The platform team forbids changing any ClusterRole that Kyverno shipped, because `helm upgrade` writes those back.

## Tasks

1. **Reproduce the problem.** Create a namespace named `carts`. Check that no `ResourceQuota` named `default-quota` exists in it.
2. **Grant the permission.** Create a `ClusterRole` named `kyverno-generate-resourcequota` that carries the label `rbac.kyverno.io/aggregate-to-background-controller: "true"`. It must allow `get`, `list`, `watch`, `create` and `update` on `resourcequotas` in the core API group. Do not edit any ClusterRole that Kyverno shipped.
3. **Prove the fix.** Create a second namespace named `checkout-svc`. The `ResourceQuota` `default-quota` (with `pods: "10"`) must exist in it.
