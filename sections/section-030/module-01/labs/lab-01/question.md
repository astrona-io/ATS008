# Question

Solve this question on: `terminal`

1.  Use `helm upgrade` to set the background controller's `extraArgs` so it runs with the flag `--genWorkers=5`.
2.  Use `helm upgrade` to set the reports controller's `extraArgs` so it runs with the flag `--backgroundScanInterval=30m`.
3.  Wait for both Deployments to finish rolling out, then confirm both flags actually appear in the live Deployments' container `args`.
