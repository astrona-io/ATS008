# Overview: Helm Install and Configuration (Playground)

This playground gives you a fresh training solar system for installing Kyverno with Helm. There is no grading. Nothing is installed yet, so you start from an empty cluster and a kit depot that is already on your list.

## What's in the box

| Item | State at the start |
| --- | --- |
| Cluster | A single-node `kind` cluster with `kubectl` and `helm` ready |
| Helm repository | `kyverno` (`https://kyverno.github.io/kyverno/`) is added and updated |
| Kyverno | Not installed. There is no `kyverno` namespace and no Kyverno custom resource definition |

## Helpers

These shell helpers show the three layers of an install in one go. Paste them into your shell.

```sh
show_install() {
  kubectl get pods -n kyverno
  kubectl get crd | grep kyverno.io
  helm list -n kyverno
}

show_admission_settings() {
  kubectl get deploy kyverno-admission-controller -n kyverno \
    -o jsonpath='{.spec.replicas}{"\n"}{.spec.template.spec.containers[0].resources}{"\n"}'
}
```

## Practice tasks

- Run `helm repo list` and check that `kyverno` is in the list. Run `helm show chart kyverno/kyverno` and read the chart and application versions.
- Install the baseline: `helm install kyverno kyverno/kyverno -n kyverno --create-namespace`. Then run `show_install` and check all three layers.
- Render the chart without installing it, with `helm template kyverno kyverno/kyverno -n kyverno --set admissionController.replicas=2`. Find the `kyverno-admission-controller` Deployment and read its `replicas`.
- Run the same render with the wrong path `admissionController.resources.requests.cpu=100m`. Look for `100m` in the output and notice that nothing changed and Helm gave no error.
- Save a values file with `admissionController.replicas: 2` and the `container.resources.requests` from the course. Apply it with `helm upgrade --install kyverno kyverno/kyverno -n kyverno -f values.yaml`. Run `show_admission_settings` and `helm history kyverno -n kyverno`.
- Run `helm get values kyverno -n kyverno` and then the same command with `-a`. Compare the two lists.
- Extend `config.excludeGroups` in a second values file and read the result back from the `kyverno` ConfigMap in the `kyverno` namespace.
