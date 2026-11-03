# Overview: Installing from Manifests and Removing Kyverno Cleanly (Playground)

This playground gives you a training solar system where Kyverno already runs. There is no grading. You use it to look at the release file, to remove Kyverno, and to check for debris.

## What's in the box

| Item | State at the start |
| --- | --- |
| Cluster | A single-node `kind` cluster with `kubectl` and `helm` ready |
| Kyverno | Installed with Helm: release `kyverno` in namespace `kyverno`, default values, the latest chart |
| Policy | `ClusterPolicy` `require-owner-label` in `Enforce` mode. A Pod outside `kube-system` and `kyverno` needs a non-empty `owner` label |
| Helm repository | `kyverno` (`https://kyverno.github.io/kyverno/`) is added |

## Helpers

`show_leftovers` runs every leftover check in one go. Run it before and after each removal step.

```sh
show_leftovers() {
  echo "--- helm releases"
  helm list -A --all
  echo "--- webhook configurations"
  kubectl get validatingwebhookconfigurations,mutatingwebhookconfigurations
  echo "--- custom resource definitions"
  kubectl get crd -o name | grep -E 'kyverno.io$|wgpolicyk8s.io$'
  echo "--- namespace"
  kubectl get namespace kyverno
}

try_pod() {
  kubectl run owner-check --image=registry.k8s.io/pause:3.9 --restart=Never -n default
  kubectl delete pod owner-check -n default --ignore-not-found --wait=false
}
```

`try_pod` creates a Pod without an `owner` label. While the policy runs, the request is refused. After a clean removal it is accepted.

## Practice tasks

- Run `show_leftovers` and `try_pod` before you change anything, and notice that the Pod is refused.
- Download the release file with `curl -sL https://github.com/kyverno/kyverno/releases/download/v1.19.2/install.yaml -o install.yaml`. Count its custom resource definitions with `grep -c '^kind: CustomResourceDefinition' install.yaml`, and search it for a `Job` or a webhook configuration.
- Run `kubectl create -f install.yaml --dry-run=server` and read the `AlreadyExists` errors. Nothing is changed.
- Save the policy with `kubectl get clusterpolicy -o yaml > policies-backup.yaml`.
- Render the chart with `helm template kyverno kyverno/kyverno -n kyverno` and find the two `pre-delete` Jobs and the ConfigMap that has the `keep` annotation.
- Run `helm uninstall kyverno -n kyverno`, then `show_leftovers` and `try_pod`. Work out for yourself which objects remain.
- Remove the leftovers in order: webhook configurations, custom resource definitions, namespace. Run `show_leftovers` after each step.
- Check the policy report definitions that end in `wgpolicyk8s.io`, and decide whether to remove them.
