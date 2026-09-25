# Solution Walkthrough

Follow these steps to install Kyverno for HA with right-sized resource requests:

---

## Step 1: Install with HA Replicas and Resource Requests

```sh
helm install kyverno kyverno/kyverno -n kyverno --create-namespace \
  --set admissionController.replicas=3 \
  --set backgroundController.replicas=2 \
  --set cleanupController.replicas=2 \
  --set reportsController.replicas=2 \
  --set admissionController.container.resources.requests.cpu=200m \
  --set admissionController.container.resources.requests.memory=256Mi
```

---

## Step 2: Wait for Rollout

```sh
kubectl -n kyverno rollout status deployment/kyverno-admission-controller --timeout=180s
kubectl -n kyverno rollout status deployment/kyverno-background-controller --timeout=180s
kubectl -n kyverno rollout status deployment/kyverno-reports-controller --timeout=180s
kubectl -n kyverno rollout status deployment/kyverno-cleanup-controller --timeout=180s
```

---

## Step 3: Verify Replicas and Resources

```sh
kubectl get deploy -n kyverno
kubectl get deploy kyverno-admission-controller -n kyverno \
  -o jsonpath='{.spec.template.spec.containers[0].resources.requests}'
```

Confirm replicas read `3/3`, `2/2`, `2/2`, `2/2`, and the resources output shows `cpu: 200m` and `memory: 256Mi`.

Once verified, run the local validation suite to pass the lab!
