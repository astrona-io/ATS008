# Question

Solve this question on: `terminal`

Kyverno is installed with Helm in the namespace `kyverno`. The namespaces `salvage-yard` and `outpost` exist. The cleanup controller runs as the service account `kyverno-cleanup-controller` in `kyverno`.

1.  Check whether the cleanup controller may delete ConfigMaps in `salvage-yard`, with `kubectl auth can-i ... --as=system:serviceaccount:kyverno:kyverno-cleanup-controller`.
2.  Give the cleanup controller the permission it needs: create a `ClusterRole` named `cleanup-configmaps` that allows `get`, `list`, `watch` and `delete` on `configmaps` and carries the label `rbac.kyverno.io/aggregate-to-cleanup-controller: "true"`.
3.  Create a `CleanupPolicy` (API version `kyverno.io/v2`) named `remove-scrap` in the namespace `salvage-yard`. It must delete every ConfigMap that has the label `scrap: "true"`, and it must run every minute (`schedule: "* * * * *"`).
4.  Check that the policy ran: read `status.lastExecutionTime` of the policy.

Only ConfigMaps with `scrap: "true"` in `salvage-yard` may be removed. The grader creates its own test ConfigMaps and waits up to three minutes for the labelled one to disappear.
