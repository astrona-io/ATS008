# Solution Walkthrough

Follow these steps to enable, author, and prove out the exception:

---

## Step 1: Confirm the CRD Surface
```sh
kubectl get crd | grep kyverno.io
```
Expect `clusterpolicies.kyverno.io`, `policies.kyverno.io`, `policyexceptions.policies.kyverno.io`, the report CRDs, and the rest of Kyverno's registered CRDs.

---

## Step 2: Enable PolicyException on the Admission Controller
```sh
kubectl patch deployment kyverno-admission-controller -n kyverno --type=json \
  -p='[{"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--enablePolicyException=true"},
       {"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--exceptionNamespace=checkout"}]'
kubectl rollout status deployment/kyverno-admission-controller -n kyverno --timeout=180s
```

---

## Step 3: Author the PolicyException

Create `except-checkout-smoke-test.yaml`:
```yaml
apiVersion: policies.kyverno.io/v1
kind: PolicyException
metadata:
  name: except-checkout-smoke-test
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
          names:
            - smoke-test
          namespaces:
            - checkout
```
```sh
kubectl apply -f except-checkout-smoke-test.yaml
```

---

## Step 4: Confirm the Exempted Pod Is Admitted
```sh
kubectl run smoke-test --image=nginx:alpine -n checkout
kubectl get pod smoke-test -n checkout
```
Despite carrying no `owner` label, `smoke-test` is admitted — the exception exempts it from `check-owner-label`.

---

## Step 5: Confirm a Non-Exempt Pod Is Still Blocked
```sh
kubectl run no-owner-pod --image=nginx:alpine -n checkout
```
Expect the API server to reject this with an admission error referencing `require-owner-label`, since `no-owner-pod` matches no exception.

---

## Step 6: Read the PolicyReport
```sh
kubectl get policyreport -n checkout
```
Once verified, run the local validation suite to pass the lab!
