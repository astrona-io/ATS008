# Solution Walkthrough

Follow these steps to install Kyverno for high availability and confirm it:

---

## Step 1: Install with the HA Replica Counts

```sh
helm install kyverno kyverno/kyverno -n kyverno --create-namespace \
  --set admissionController.replicas=3 \
  --set backgroundController.replicas=2 \
  --set cleanupController.replicas=2 \
  --set reportsController.replicas=2
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

## Step 3: Inspect Leader Election

```sh
kubectl get lease -n kyverno
```

Pick the lease belonging to the background controller and inspect it:

```sh
kubectl describe lease <background-controller-lease-name> -n kyverno
```

The `Holder Identity` field names the Pod currently acting as leader. Only that one Pod is actually doing background-scan/generate work right now, even though two replicas are Running.

---

## Step 4: Confirm the Admission Controller Replica Count

```sh
kubectl get pods -n kyverno --show-labels | grep admission-controller
```

Use whatever label the output shows (commonly `app.kubernetes.io/component=admission-controller`) to confirm 3 Running pods:

```sh
kubectl get pods -n kyverno -l app.kubernetes.io/component=admission-controller
```

---

## Step 5: Verify Your Configuration

```sh
kubectl get deploy -n kyverno
```

Confirm the replica counts read `3/3`, `2/2`, `2/2`, `2/2` for admission, background, cleanup, and reports respectively.

Once verified, run the local validation suite to pass the lab!
