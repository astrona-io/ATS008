# Solution Walkthrough

Follow these steps to set and verify both controller flags:

---

## Step 1: Set the background controller's genWorkers

```sh
helm upgrade --reuse-values -n kyverno kyverno kyverno/kyverno \
  --set backgroundController.extraArgs[0]=--genWorkers=5

kubectl rollout status deployment/kyverno-background-controller -n kyverno --timeout=120s
```

`--reuse-values` keeps every previously-set value; only `backgroundController.extraArgs` changes. Note this is a **flat** key — no `.container.` nesting, unlike the admission controller.

---

## Step 2: Set the reports controller's backgroundScanInterval

```sh
helm upgrade --reuse-values -n kyverno kyverno kyverno/kyverno \
  --set reportsController.extraArgs[0]=--backgroundScanInterval=30m

kubectl rollout status deployment/kyverno-reports-controller -n kyverno --timeout=120s
```

---

## Step 3: Verify Your Configuration

Read each Deployment's live container `args` back directly — don't just trust that the `helm upgrade` command exited successfully:

```sh
kubectl get deploy kyverno-background-controller -n kyverno \
  -o jsonpath='{.spec.template.spec.containers[0].args}'

kubectl get deploy kyverno-reports-controller -n kyverno \
  -o jsonpath='{.spec.template.spec.containers[0].args}'
```

Confirm `--genWorkers=5` appears in the first output and `--backgroundScanInterval=30m` appears in the second.

Once verified, run the local validation suite to pass the lab!
