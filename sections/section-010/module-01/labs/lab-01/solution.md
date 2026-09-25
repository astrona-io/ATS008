# Solution Walkthrough

Follow these steps to install, size, and verify the release:

---

## Step 1: Install Kyverno with the Required Values

```sh
helm install kyverno kyverno/kyverno -n kyverno --create-namespace \
  --set admissionController.replicas=2 \
  --set admissionController.container.resources.requests.cpu=100m \
  --set admissionController.container.resources.requests.memory=128Mi
```

---

## Step 2: Wait for the Admission Controller to Roll Out

```sh
kubectl rollout status deployment/kyverno-admission-controller -n kyverno --timeout=180s
```

---

## Step 3: Confirm the Release

```sh
helm list -n kyverno
```

Expect a `kyverno` row with `STATUS` `deployed`.

---

## Step 4: Verify the Requested Values Actually Landed

```sh
kubectl get deploy kyverno-admission-controller -n kyverno -o yaml
```

Confirm `spec.replicas: 2` and, under `spec.template.spec.containers[0].resources.requests`, `cpu: 100m` and `memory: 128Mi`.

---

## Step 5: Verify Your Configuration

Once verified, run the local validation suite to pass the lab!
