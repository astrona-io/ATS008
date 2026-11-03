# Question

Solve this question on: `terminal`

## Scenario

Kyverno is installed with Helm in the `kyverno` namespace at default values. The namespace `scrap` holds three ConfigMaps: `old-note-1` and `old-note-2` carry the label `expired: "true"`, and `keep-note` carries `expired: "false"`. The team wants a Kyverno cleanup policy that removes the expired notes. The cleanup controller does not have the permission to delete ConfigMaps today. Do not change any ClusterRole that Kyverno shipped, and do not give the cleanup controller more than it needs.

## Tasks

1. **Grant the permission.** Create a `ClusterRole` named `kyverno-cleanup-configmaps` with the label `rbac.kyverno.io/aggregate-to-cleanup-controller: "true"`. It must allow `get`, `list` and `delete` on `configmaps` in the core API group, and nothing else.
2. **Create the cleanup policy.** Create a `ClusterCleanupPolicy` (`apiVersion: kyverno.io/v2`) named `purge-expired-notes` with the schedule `* * * * *`. It must match `ConfigMap` objects in the namespace `scrap` that have the label `expired: "true"`.
3. **Prove the effect.** Within a few minutes `old-note-1` and `old-note-2` must be gone from `scrap`, and `keep-note` must still be there. As the cleanup controller's service account (`system:serviceaccount:kyverno:kyverno-cleanup-controller`), `kubectl auth can-i delete configmaps -n scrap` must say `yes`, and the same question for `secrets` and `pods` must say `no`.
