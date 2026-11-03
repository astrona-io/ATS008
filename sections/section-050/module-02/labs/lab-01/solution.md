# Solution Walkthrough

Follow these steps. After each step you can run `astrona submit` to see which checks pass.

---

## Step 1: Save the values file

Save this as `ha-values.yaml`:

```yaml
admissionController:
  replicas: 3
  priorityClassName: system-cluster-critical
  podDisruptionBudget:
    minAvailable: null
    maxUnavailable: 1
  topologySpreadConstraints:
    - maxSkew: 1
      topologyKey: kubernetes.io/hostname
      whenUnsatisfiable: ScheduleAnyway
      labelSelector:
        matchLabels:
          app.kubernetes.io/component: admission-controller
backgroundController:
  replicas: 2
```

Without `minAvailable: null`, Helm stops with `Cannot set both .minAvailable and .maxUnavailable`.

---

## Step 2: Install

```sh
helm install kyverno kyverno/kyverno -n kyverno --create-namespace -f ha-values.yaml
```

---

## Step 3: Wait for the rollouts

```sh
kubectl -n kyverno rollout status deployment/kyverno-admission-controller --timeout=180s
kubectl -n kyverno rollout status deployment/kyverno-background-controller --timeout=180s
```

Run `astrona submit` now. The replicas check should pass.

---

## Step 4: Check the budgets

```sh
kubectl get pdb -n kyverno
```

The admission budget shows `MAX UNAVAILABLE` `1`. Its allowed disruptions column shows `1` once all three Pods are ready. The background budget keeps the default `minAvailable` of `1`, because it has two replicas.

---

## Step 5: Check the spread rule and priority class

```sh
kubectl get deploy kyverno-admission-controller -n kyverno -o jsonpath='{.spec.template.spec.topologySpreadConstraints}{"\n"}{.spec.template.spec.priorityClassName}{"\n"}'
```

You should see your constraint and `system-cluster-critical`. Run `astrona submit` for the final result.
