# Solution Walkthrough

Two flags go on two different controllers. After each change you wait for the rollout and read the live flags back. Run `astrona submit` after each step to see which check passes.

## Step 1: Set the background controller's genWorkers

`extraArgs` is a map. Write the flag name without dashes and give it a value:

```sh
helm upgrade --reuse-values -n kyverno kyverno kyverno/kyverno \
  --set backgroundController.extraArgs.genWorkers=5
kubectl rollout status deployment/kyverno-background-controller -n kyverno --timeout=120s
```

`--reuse-values` keeps every value set before, so only `backgroundController.extraArgs` changes. The path is flat: there is no `container` in it, unlike the admission controller's path. Do not write the value as a list (`extraArgs[0]=--genWorkers=5`): the chart renders that as `--0=--genWorkers=5`.

Run `astrona submit -c sections/section-030/module-01/labs/lab-01`. The background check should pass, and the reports check should still fail.

## Step 2: Set the reports controller's backgroundScanInterval

```sh
helm upgrade --reuse-values -n kyverno kyverno kyverno/kyverno \
  --set reportsController.extraArgs.backgroundScanInterval=30m
kubectl rollout status deployment/kyverno-reports-controller -n kyverno --timeout=120s
```

The chart already starts this controller with `--backgroundScanInterval=1h`. Your flag comes later in the list and wins. Run `astrona submit` again. Both checks should pass now.

## Step 3: Verify your configuration

Read each Deployment's live flags back. Do not trust the exit code of `helm upgrade` alone:

```sh
kubectl get deploy kyverno-background-controller -n kyverno \
  -o jsonpath='{.spec.template.spec.containers[0].args}'
kubectl get deploy kyverno-reports-controller -n kyverno \
  -o jsonpath='{.spec.template.spec.containers[0].args}'
```

The first output contains `--genWorkers=5`. The second contains `--backgroundScanInterval=30m`, after the chart's own `--backgroundScanInterval=1h`.
