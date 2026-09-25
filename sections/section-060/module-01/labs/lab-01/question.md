# Question

Solve this question on: `terminal`

1.  Upgrade the existing `kyverno` Helm release in place: run `helm upgrade` with `--reuse-values` and `--set admissionController.replicas=3`.
2.  Confirm `helm status kyverno -n kyverno` reports `REVISION: 2`.
3.  Confirm `helm history kyverno -n kyverno` lists two revisions.
4.  Confirm the cluster is still healthy after the upgrade: all pods in the `kyverno` namespace are `Running`, and the `clusterpolicies.kyverno.io` CRD is still present.
