# Overview: Tuning Kyverno's Controllers with Flags (Playground)

This playground starts a fresh Kubernetes cluster with Kyverno already installed. There is no grading. Use it to read the flags of the four controllers and to change them with Helm.

## What's in the box

The single-node kind cluster runs Kubernetes 1.35.8. The `kyverno` Helm repository is added, and the release `kyverno` is installed at default values in the `kyverno` namespace.

| Deployment | Job |
| --- | --- |
| `kyverno-admission-controller` | Answers the webhook call for every matching request |
| `kyverno-background-controller` | Does generate and mutate-existing work |
| `kyverno-reports-controller` | Scans existing objects and writes policy reports |
| `kyverno-cleanup-controller` | Deletes objects on a schedule |

## Helpers

`show_flags` prints the live flags of one controller, one per line. Give it `admission`, `background`, `reports` or `cleanup`. `wait_for_crew` waits for one controller to finish rolling out.

```sh
show_flags() {
  kubectl get deploy "kyverno-$1-controller" -n kyverno \
    -o jsonpath='{range .spec.template.spec.containers[0].args[*]}{@}{"\n"}{end}'
}

wait_for_crew() {
  kubectl rollout status "deployment/kyverno-$1-controller" -n kyverno --timeout=180s
}
```

## Practice tasks

- Run `show_flags` for all four controllers and write down one flag that only one of them has.
- Render the chart with `helm template` and `--set backgroundController.extraArgs.genWorkers=5`, and find the flag in the output. Then try `--set admissionController.extraArgs.webhookTimeout=15` and notice that nothing appears.
- Apply `backgroundController.extraArgs.genWorkers=5` with `helm upgrade --reuse-values`, run `wait_for_crew background`, and read the flags again. Check which other Deployments rolled out.
- Set `reportsController.extraArgs.backgroundScanInterval=30m` and look at both `--backgroundScanInterval` lines in the live list.
- Run `helm get values kyverno -n kyverno` and `helm history kyverno -n kyverno`. Count the revisions your upgrades added.
- Change a value under `config` (for example `config.generateSuccessEvents=true`) and check that no controller Pod was replaced.
