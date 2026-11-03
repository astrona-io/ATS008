# Overview: Rolling Back and Recovering from a Bad Upgrade (Playground)

This playground is a training solar system where a refit already went wrong. There is no grading. Use it to read the flight record, roll the release back, back up policies and try the Helm value flags.

## What's in the box

A `kind` cluster with `kubectl` and `helm` ready. Kyverno is a Helm release called `kyverno` in the namespace `kyverno`.

| Object | What it is |
| --- | --- |
| Revision 1 | The clean install at default values |
| Revision 2 | A broken upgrade that points the admission controller at an image tag that does not exist. It was made without `--wait`, so Helm records it as deployed |
| Namespace `finance` | A planet with a rule book |
| `ClusterPolicy` `require-cost-center-label` | Blocks a Pod in `finance` that has no `cost-center` label |

The old admission controller Pod probably still runs next to a new one that cannot pull its image, so admission still works while the release is broken.

## Helpers

`show_flight_record` prints the flight record and the release status. `check_controllers` waits for every controller and lists the Pods. `try_unlabeled_pod` asks the API server to check an unlabeled Pod in `finance` without creating it.

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

try_unlabeled_pod() {
  kubectl -n finance run unlabeled-test --image=busybox --dry-run=server
}
```

## Practice tasks

- Run `show_flight_record` and `kubectl get pods -n kyverno`. Find the Pod with an image pull error, and read why with `kubectl describe pod` on it.
- Read the values of revision 2 with `helm get values kyverno -n kyverno --revision 2`.
- Roll back with `helm rollback kyverno 1 -n kyverno --wait --timeout 5m`, then run `helm history kyverno -n kyverno --show-rollback-revision` and `check_controllers`.
- Run `try_unlabeled_pod` and read the refusal.
- Back up the policy with `kubectl get clusterpolicies.kyverno.io -o yaml > policy-backup.yaml`. Delete the policy, try `kubectl create -f policy-backup.yaml`, and see why the API server refuses it. Remove the lines it does not allow and try again.
- Compare `--reuse-values`, `--reset-values` and `--reset-then-reuse-values` with `helm get values kyverno -n kyverno` after each upgrade.
- Read the chart's Kubernetes version limit with `helm show chart kyverno/kyverno | grep kubeVersion`.
