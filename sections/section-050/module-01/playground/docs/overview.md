# Overview: Running Kyverno Highly Available (Playground)

This playground gives you an empty training solar system. There is no grading. You install Kyverno yourself and look at how many ships (Pods) each crew (controller) runs.

## What's in the box

A single-node `kind` cluster (one space dock). The `kyverno` Helm repository is added and up to date. Kyverno is not installed. The namespace `kyverno` does not exist yet.

Because there is only one node, you can see replica counts and leader election here. You cannot see Pods spread over several nodes. Every Pod you start lands on the same node.

## Helpers

```sh
show_replicas() {
  kubectl get deploy -n kyverno -o custom-columns=NAME:.metadata.name,WANT:.spec.replicas,READY:.status.readyReplicas
}
show_leases() {
  kubectl get lease -n kyverno -o custom-columns=NAME:.metadata.name,HOLDER:.spec.holderIdentity
}
```

## Practice tasks

- Run `helm template kyverno kyverno/kyverno -n kyverno | grep -n "replicas:"` and see what the chart sets when you give it no replica values.
- Install Kyverno with the HA replica counts from the module, then run `show_replicas` and `show_leases`.
- Delete the Pod named as the holder of one lease and run `show_leases` again. Watch the holder change.
- Upgrade the release with `--set backgroundController.replicas=3` and check that the work still has one leader.
- Run `kubectl get pods -n kyverno -o wide` and note that every Pod shows the same node.
