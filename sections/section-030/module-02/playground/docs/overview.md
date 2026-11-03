# Overview: The Kyverno ConfigMap (Playground)

This playground starts a fresh Kubernetes cluster with Kyverno already installed. There is no grading. Use it to read the Kyverno ConfigMap and to change it through Helm values.

## What's in the box

The single-node kind cluster runs Kubernetes 1.35.8. The release `kyverno` is installed at default values in the `kyverno` namespace. A namespace named `mission-ops` exists and is empty.

| Object | What it is |
| --- | --- |
| ConfigMap `kyverno` (namespace `kyverno`) | The settings that the four controllers read live, built from the chart's `config` values |
| ConfigMap `kyverno-metrics` | Metrics settings, built from `metricsConfig` |
| Namespace `mission-ops` | A planet for your exercises |

## Helpers

`show_board` prints the value of one key of the Kyverno ConfigMap. `list_board_keys` prints the names of all keys. `show_filters` prints the resource filters, one per line.

```sh
show_board() {
  kubectl get configmap kyverno -n kyverno -o jsonpath="{.data.$1}"
  echo
}

list_board_keys() {
  kubectl get configmap kyverno -n kyverno \
    -o go-template='{{range $key, $value := .data}}{{$key}}{{"\n"}}{{end}}'
}

show_filters() {
  kubectl get configmap kyverno -n kyverno -o jsonpath='{.data.resourceFilters}' | tr ' ' '\n'
}
```

## Practice tasks

- Run `list_board_keys`, then `show_board excludeGroups`. Find which keys are missing compared with the `config` block in `helm show values kyverno/kyverno`.
- Count the entries from `show_filters` with `show_filters | wc -l`.
- Render the ConfigMap with `helm template kyverno kyverno/kyverno -n kyverno -s templates/config/configmap.yaml` and compare it with the live one.
- Add `config.excludeUsernames` with a service account from `mission-ops`, apply it with `helm upgrade --reuse-values`, and run `kubectl get pods -n kyverno` before and after. Check that no Pod was replaced.
- Add `mission-ops` with `config.resourceFiltersIncludeNamespaces` and check the last line of `show_filters`. Then remove the namespace again with `config.resourceFiltersExcludeNamespaces` and see what happens to the defaults.
- Set `config.generateSuccessEvents=true`, then run `helm get values kyverno -n kyverno` and `helm get manifest kyverno -n kyverno` and find the new value in both.
- Edit the ConfigMap by hand with `kubectl edit`, run `helm upgrade --reuse-values` with no changes, and see what happens to your edit.
