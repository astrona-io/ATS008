# Question

Solve this question on: `terminal`

1.  Create a namespace named `carts`. Observe (e.g. via `kubectl get events -n carts` or `kubectl get updaterequest -A`) that the `generate-default-quota` policy did **not** successfully create a `ResourceQuota` named `default-quota` inside it, because the background controller's ServiceAccount lacks the RBAC permission to create `resourcequotas`.
2.  Author a new `ClusterRole` named `kyverno-generate-resourcequota` carrying the label `rbac.kyverno.io/aggregate-to-background-controller: "true"`, granting `get`, `list`, `watch`, `create`, and `update` on `resourcequotas` (core API group). Do **not** modify any of Kyverno's own shipped ClusterRoles.
3.  Create a second namespace named `checkout-svc` and confirm that the `default-quota` ResourceQuota is now generated successfully inside it.
