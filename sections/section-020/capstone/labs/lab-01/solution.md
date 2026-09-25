# Solution Walkthrough

---

## Step 1: Enable PolicyException
```sh
kubectl patch deployment kyverno-admission-controller -n kyverno --type=json \
  -p='[{"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--enablePolicyException=true"},
       {"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--exceptionNamespace=checkout"}]'
kubectl rollout status deployment/kyverno-admission-controller -n kyverno --timeout=180s
```

---

## Step 2: Exempt Batch Pods from require-owner-label

```yaml
apiVersion: policies.kyverno.io/v1
kind: PolicyException
metadata:
  name: except-checkout-batch-jobs
  namespace: checkout
spec:
  exceptions:
    - policyName: require-owner-label
      ruleNames:
        - check-owner-label
  match:
    any:
      - resources:
          kinds:
            - Pod
          namespaces:
            - checkout
          selector:
            matchLabels:
              job-type: batch
```
```sh
kubectl apply -f except-checkout-batch-jobs.yaml
```

---

## Step 3: Exempt nightly-batch from require-cost-center-label

```yaml
apiVersion: policies.kyverno.io/v1
kind: PolicyException
metadata:
  name: except-checkout-nightly-batch
  namespace: checkout
spec:
  exceptions:
    - policyName: require-cost-center-label
      ruleNames:
        - check-cost-center-label
  match:
    any:
      - resources:
          kinds:
            - Deployment
          names:
            - nightly-batch
          namespaces:
            - checkout
```
```sh
kubectl apply -f except-checkout-nightly-batch.yaml
```

---

## Step 4: Confirm the First Exemption
```sh
kubectl run batch-worker --image=nginx:alpine -n checkout --labels="job-type=batch"
kubectl get pod batch-worker -n checkout
```

---

## Step 5: Confirm the Control Case
```sh
kubectl run unlabeled-worker --image=nginx:alpine -n checkout
```
Expect this to be rejected by `require-owner-label` — it matches neither `job-type: batch` nor carries an `owner` label.

---

## Step 6: Confirm the Second Exemption
```sh
kubectl create deployment nightly-batch -n checkout --image=nginx:alpine
kubectl get deployment nightly-batch -n checkout
```
Once verified, run the local validation suite to pass the lab!
