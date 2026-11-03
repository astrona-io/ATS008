# Solution Walkthrough

You configure two controllers with one values file and one `helm upgrade`. The two controllers use different paths, and that difference is the point of the task. After the upgrade you read the live flags back. Run `astrona submit` after the upgrade to see both checks.

## Step 1: Write the values file

Save this as `capstone-030-values.yaml`:

```yaml
admissionController:
  container:
    extraArgs:
      webhookTimeout: 15
      enablePolicyException: true
      exceptionNamespace: capstone-030

cleanupController:
  extraArgs:
    ttlReconciliationInterval: 5m
```

`extraArgs` is a map. Each key is a flag name without the dashes, and the chart writes it as `--key=value`. The admission controller's map sits one level deeper, under `container`. If you put it directly under `admissionController`, Helm raises no error, but no template reads it and the flags never arrive.

The chart already starts the admission controller with `--enablePolicyException=false`. Your `--enablePolicyException=true` comes later in the list, so it wins.

You can check where the flags land before you apply anything:

```sh
helm template kyverno kyverno/kyverno -n kyverno -f capstone-030-values.yaml | grep -n "webhookTimeout\|exceptionNamespace\|ttlReconciliationInterval"
```

## Step 2: Apply the upgrade

```sh
helm upgrade --reuse-values -n kyverno kyverno kyverno/kyverno -f capstone-030-values.yaml
kubectl rollout status deployment/kyverno-admission-controller -n kyverno --timeout=180s
kubectl rollout status deployment/kyverno-cleanup-controller -n kyverno --timeout=180s
```

Run `astrona submit -c sections/section-030/capstone/labs/lab-01`. Both checks should pass.

## Step 3: Verify your configuration

```sh
kubectl get deploy kyverno-admission-controller -n kyverno \
  -o jsonpath='{.spec.template.spec.containers[0].args}'
kubectl get deploy kyverno-cleanup-controller -n kyverno \
  -o jsonpath='{.spec.template.spec.containers[0].args}'
```

The admission controller's output contains `--webhookTimeout=15`, `--enablePolicyException=true` and `--exceptionNamespace=capstone-030`. The cleanup controller's output contains `--ttlReconciliationInterval=5m`.
