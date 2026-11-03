# Overview: Sizing, Disruption Budgets and Spreading Replicas (Playground)

This playground gives you a running Kyverno station at default settings. There is no grading. You refit it with `helm upgrade` and read the result from the live objects.

## What's in the box

A single-node `kind` cluster (one space dock). Kyverno is installed with Helm at default values: release `kyverno` in namespace `kyverno`, one replica per controller, no PodDisruptionBudget and no topology spread constraints.

Because there is only one node, you can see replica counts, resource requests, PodDisruptionBudgets and Leases. You cannot see Pods spread over several nodes. A node drain here would evict every Pod on the only node, so do not run one.

## Helpers

```sh
show_sizing() {
  kubectl get deploy -n kyverno -o custom-columns=NAME:.metadata.name,REPLICAS:.spec.replicas,REQ_CPU:.spec.template.spec.containers[0].resources.requests.cpu,REQ_MEM:.spec.template.spec.containers[0].resources.requests.memory
}
show_budgets() {
  kubectl get pdb -n kyverno
}
show_leases() {
  kubectl get lease -n kyverno -o custom-columns=NAME:.metadata.name,HOLDER:.spec.holderIdentity
}
```

## Practice tasks

- Run `helm show values kyverno/kyverno` and find the `resources`, `replicas`, `podDisruptionBudget`, `topologySpreadConstraints` and `priorityClassName` keys for each controller.
- Run `show_sizing`, then upgrade the admission controller to three replicas and run it again.
- Run `show_budgets` before and after raising a controller above one replica.
- Give the admission controller three replicas and set `maxUnavailable` without clearing `minAvailable`. Read the error that Helm prints.
- Add a `topologySpreadConstraints` entry to the admission controller and read it back from the live Deployment.
- Delete the Pod that holds a lease and run `show_leases` until the holder changes.
