# Solution Walkthrough

Follow these steps to upgrade the release and verify it landed cleanly:

---

## Step 1: Upgrade the Release

```sh
helm upgrade kyverno kyverno/kyverno -n kyverno --reuse-values --set admissionController.replicas=3
```

`--reuse-values` carries forward the baseline install's existing values so only `admissionController.replicas` changes — nothing else is reset to chart defaults.

---

## Step 2: Confirm the Revision Bumped

```sh
helm status kyverno -n kyverno
```

Expect a `REVISION: 2` line in the output (revision `1` was the original install from the bootstrap script).

---

## Step 3: Confirm the Revision History

```sh
helm history kyverno -n kyverno
```

Expect two rows beneath the header: revision `1` (install) and revision `2` (upgrade).

---

## Step 4: Confirm the Cluster Is Still Healthy

```sh
kubectl rollout status deployment/kyverno-admission-controller -n kyverno --timeout=120s
kubectl get pods -n kyverno
kubectl get crd clusterpolicies.kyverno.io
```

Expect every pod in the `kyverno` namespace `Running`, the admission controller Deployment now showing `3/3` ready replicas, and the `clusterpolicies.kyverno.io` CRD still present — proof the upgrade didn't disturb Kyverno's CRD surface.

---

## Step 5: Verify Your Configuration

```sh
kubectl get deploy kyverno-admission-controller -n kyverno -o jsonpath='{.spec.replicas}'
```

Once this reads `3` and every check above passes, run the local validation suite to pass the lab!
