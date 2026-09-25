# Solution Walkthrough

Follow these steps to configure both controllers in one upgrade:

---

## Step 1: Write the values file

Create `capstone-030-values.yaml`:
```yaml
admissionController:
  container:
    extraArgs:
      - --webhookTimeout=15
      - --enablePolicyException=true
      - --exceptionNamespace=capstone-030

cleanupController:
  extraArgs:
    - --ttlReconciliationInterval=5m
```

Notice the admission controller's `extraArgs` nests one level deeper (`container.extraArgs`) than the cleanup controller's (`extraArgs` directly on the controller block) — this is the exact nesting inconsistency covered in Part 2. Getting this wrong on either controller means the flag values sit in an unread part of the values tree and never reach the container.

---

## Step 2: Apply the upgrade

```sh
helm upgrade --reuse-values -n kyverno kyverno kyverno/kyverno -f capstone-030-values.yaml

kubectl rollout status deployment/kyverno-admission-controller -n kyverno --timeout=180s
kubectl rollout status deployment/kyverno-cleanup-controller -n kyverno --timeout=180s
```

---

## Step 3: Verify Your Configuration

```sh
kubectl get deploy kyverno-admission-controller -n kyverno \
  -o jsonpath='{.spec.template.spec.containers[0].args}'

kubectl get deploy kyverno-cleanup-controller -n kyverno \
  -o jsonpath='{.spec.template.spec.containers[0].args}'
```

Confirm the admission controller's output contains all three of `--webhookTimeout=15`, `--enablePolicyException=true`, and `--exceptionNamespace=capstone-030`, and the cleanup controller's output contains `--ttlReconciliationInterval=5m`.

Once verified, run the local validation suite to pass the lab!
