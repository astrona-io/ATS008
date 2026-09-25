# Solution Walkthrough

Follow these steps to build the values file, apply it, and verify each setting:

---

## Step 1: Write the Values File

Create `values.yaml`:
```yaml
admissionController:
  replicas: 2

cleanupController:
  enabled: false

config:
  excludeGroups:
    - "system:serviceaccounts:kube-system"
    - "system:nodes"
    - "system:serviceaccounts:ci"
```

Note that `excludeGroups` explicitly re-lists Kyverno's two built-in defaults alongside the new entry — Helm replaces list values wholesale, it does not merge them.

---

## Step 2: Apply with helm upgrade --install

```sh
helm upgrade --install kyverno kyverno/kyverno -n kyverno --create-namespace -f values.yaml
```

`--install` makes this safe to run whether or not the release already exists.

---

## Step 3: Verify the Replica Count

```sh
kubectl get deploy kyverno-admission-controller -n kyverno -o jsonpath='{.spec.replicas}'
```
Expect `2`.

---

## Step 4: Verify the Cleanup Controller Is Disabled

```sh
kubectl get deploy kyverno-cleanup-controller -n kyverno
```
Expect either "not found" or a Deployment with `0` replicas, depending on how the chart implements the toggle.

---

## Step 5: Verify the Exclude Groups

```sh
kubectl get cm -n kyverno -o yaml | grep -E "system:serviceaccounts:ci|system:serviceaccounts:kube-system|system:nodes"
```
Expect all three strings present — confirming the new entry was added without losing the defaults.

---

## Step 6: Verify Your Configuration

Once verified, run the local validation suite to pass the lab!
