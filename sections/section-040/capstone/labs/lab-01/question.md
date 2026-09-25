# Question

Solve this question on: `terminal`

1.  Create a namespace named `orders`. Confirm the `generate-network-policy` policy did **not** create a `NetworkPolicy` named `default-deny` inside it, due to missing RBAC on the background controller's ServiceAccount.
2.  Author a new `ClusterRole` named `kyverno-generate-networkpolicy` carrying the label `rbac.kyverno.io/aggregate-to-background-controller: "true"`, granting `get`, `list`, `watch`, `create`, and `update` on `networkpolicies` in the `networking.k8s.io` API group. Do **not** modify any of Kyverno's own shipped ClusterRoles.
3.  Create a second namespace named `billing-svc` and confirm the `default-deny` NetworkPolicy is now generated inside it.
