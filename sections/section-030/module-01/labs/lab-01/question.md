# Question

Solve this question on: `terminal`

Kyverno is installed with Helm as release `kyverno` in namespace `kyverno`. Use `helm upgrade` for every change.

1.  Set the background controller's `extraArgs` so it runs with the flag `--genWorkers=5`.
2.  Set the reports controller's `extraArgs` so it runs with the flag `--backgroundScanInterval=30m`.
3.  Wait for both Deployments to finish rolling out, then confirm both flags appear in the live Deployments' container `args`.
