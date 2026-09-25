# Question

Solve this question on: `terminal`

A `ClusterPolicy` named `require-cost-center-label` is already running. Run the full backup-upgrade-verify flow around a Kyverno upgrade:

1.  Back up every `ClusterPolicy` on the cluster to a file named `policy-backup.yaml` in your home directory: `kubectl get clusterpolicy -o yaml > ~/policy-backup.yaml`.
2.  Upgrade the `kyverno` Helm release in one command: `helm upgrade` with `--reuse-values`, `--set admissionController.replicas=3`, and `--set backgroundController.extraArgs[0]=--genWorkers=15`.
3.  Confirm `require-cost-center-label` still exists and is unchanged after the upgrade.
4.  Confirm `~/policy-backup.yaml` exists and contains `require-cost-center-label`.
5.  Confirm `helm history kyverno -n kyverno` shows at least 2 revisions.
