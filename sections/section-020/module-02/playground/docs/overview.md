# Overview: Cleaning Up Resources (Playground)

This playground runs the **current Kyverno Helm chart** (chart 3.9.x with Kyverno v1.19.x), installed with Helm as release `kyverno`. It has no grading.

## What is in the box

| Item | State |
| --- | --- |
| Namespace `kyverno` | Four controllers, including `kyverno-cleanup-controller` |
| Namespace `docking-bay` | The ConfigMaps `old-scrap` (label `scrap: "true"`) and `keep-me` (no label) |
| Cleanup policies | None |
| Cleanup controller clearance | It may not delete ConfigMaps yet |

## Helpers

`can_cleanup_delete` asks the clearance office if the salvage crew may delete a kind on `docking-bay`. `show_scrap_state` lists the ConfigMaps with their labels.

```sh
can_cleanup_delete() {
  kubectl auth can-i delete "$1" -n docking-bay --as=system:serviceaccount:kyverno:kyverno-cleanup-controller
}
show_scrap_state() {
  kubectl get configmap -n docking-bay --show-labels
}
```

## Practice tasks

- Run `can_cleanup_delete configmaps` and note the answer. Add a labelled `ClusterRole` and run it again.
- Write a `CleanupPolicy` named `remove-scrap` for `docking-bay` with the schedule `* * * * *`, and watch `old-scrap` disappear while `keep-me` stays.
- Read `status.lastExecutionTime` of the policy and the cleanup controller log.
- Add a `conditions` block that needs a second label, and test it with a new ConfigMap.
- Create a ConfigMap with `cleanup.kyverno.io/ttl=2m` and watch it expire.
- Read the controller `args` and find `--ttlReconciliationInterval`.
