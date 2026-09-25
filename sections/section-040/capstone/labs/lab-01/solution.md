# Solution Walkthrough

Follow these steps to diagnose the RBAC gap and fix it correctly:

---

## Step 1: Confirm the NetworkPolicy Was Not Generated

```sh
kubectl create namespace orders
kubectl get networkpolicy -n orders
```
Expect no `default-deny` NetworkPolicy. Check for evidence of the RBAC failure:
```sh
kubectl get events -n orders
kubectl get updaterequest -A
```

---

## Step 2: Author the Aggregated ClusterRole

Create `kyverno-generate-networkpolicy.yaml`:
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: kyverno-generate-networkpolicy
  labels:
    rbac.kyverno.io/aggregate-to-background-controller: "true"
rules:
  - apiGroups: ["networking.k8s.io"]
    resources: ["networkpolicies"]
    verbs: ["get", "list", "watch", "create", "update"]
```
Apply it:
```sh
kubectl apply -f kyverno-generate-networkpolicy.yaml
```
No Kyverno-shipped ClusterRole is touched — this is a brand-new object aggregated in via the label.

---

## Step 3: Confirm the Permission Landed

```sh
kubectl auth can-i create networkpolicies.networking.k8s.io \
  --as=system:serviceaccount:kyverno:kyverno-background-controller
```
Expect `yes`.

---

## Step 4: Confirm the Fix Works Going Forward

```sh
kubectl create namespace billing-svc
kubectl get networkpolicy default-deny -n billing-svc -o yaml
```
The `default-deny` NetworkPolicy should now exist in `billing-svc` with an empty `podSelector` and both `Ingress`/`Egress` policy types.

---

## Step 5: Verify Your Configuration

```sh
kubectl get clusterrole kyverno-generate-networkpolicy -o yaml
kubectl get networkpolicy default-deny -n billing-svc
```
Once verified, run the local validation suite to pass the lab!
