# Overview: Upgrading a Running Kyverno Installation (Playground)

This playground is a training solar system for refitting a Kyverno station. There is no grading. Use it to run `helm upgrade`, read the flight record and check that the controllers came back healthy.

## What's in the box

A `kind` cluster with `kubectl` and `helm` already set up. The `kyverno` Helm repository is added. Kyverno is installed with Helm at the chart's default values: release `kyverno` in the namespace `kyverno`, at revision 1. No policies exist yet.

| Object | What it is |
| --- | --- |
| Release `kyverno` (namespace `kyverno`) | The assembled station, at revision 1 |
| Four Deployments | `kyverno-admission-controller`, `kyverno-background-controller`, `kyverno-reports-controller`, `kyverno-cleanup-controller` |
| CRDs such as `clusterpolicies.kyverno.io` | The forms the registry desk accepts, installed by the release |

## Helpers

`show_flight_record` prints the flight record and the state of the release. `check_controllers` waits for each controller to finish its rollout and then lists the pods.

```sh
show_flight_record() {
  helm history kyverno -n kyverno
  helm status kyverno -n kyverno
}

check_controllers() {
  for deploy in kyverno-admission-controller kyverno-background-controller kyverno-reports-controller kyverno-cleanup-controller; do
    kubectl -n kyverno rollout status "deployment/${deploy}" --timeout=180s
  done
  kubectl get pods -n kyverno
}
```

## Practice tasks

- Run `show_flight_record` and note the revision, the status and the chart version.
- List the chart versions in the repository with `helm search repo kyverno/kyverno --versions`.
- Upgrade with `helm upgrade kyverno kyverno/kyverno -n kyverno --reuse-values --set admissionController.replicas=3`, then run `show_flight_record` and `check_controllers`.
- Read the values you supplied with `helm get values kyverno -n kyverno`, and every value in use with `helm get values kyverno -n kyverno -a`.
- Find the CRDs inside the release with `helm get manifest kyverno -n kyverno`, and find the upgrade hook with `helm get hooks kyverno -n kyverno`.
- Save a `ClusterPolicy`, apply it, and back it up with `kubectl get clusterpolicy -o yaml > policy-backup.yaml`. Upgrade again, and check that the policy did not change.
- Run `kyverno migrate --help` if you have the Kyverno command line on your machine.
