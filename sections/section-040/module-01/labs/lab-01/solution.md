# Solution Walkthrough

Follow these steps to diagnose the RBAC gap and fix it correctly:

---

## Step 1: Confirm the ResourceQuota Was Not Generated

```sh
kubectl create namespace carts
kubectl get resourcequota -n carts
```
Expect no `default-quota` ResourceQuota to exist. Check for evidence of the RBAC failure:
```sh
kubectl get events -n carts
kubectl get updaterequest -A
```
You should see an error referencing forbidden/permission-denied on `resourcequotas`, or an `UpdateRequest` stuck in a failed/pending state.

---

## Step 2: Author the Aggregated ClusterRole

Create `kyverno-generate-resourcequota.yaml`:
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: kyverno-generate-resourcequota
  labels:
    rbac.kyverno.io/aggregate-to-background-controller: "true"
rules:
  - apiGroups: [""]
    resources: ["resourcequotas"]
    verbs: ["get", "list", "watch", "create", "update"]
```
Apply it:
```sh
kubectl apply -f kyverno-generate-resourcequota.yaml
```
This does not touch any ClusterRole Kyverno itself shipped — it is a brand-new object that Kubernetes' ClusterRole aggregation folds into the background controller's effective permissions automatically.

---

## Step 3: Confirm the Permission Landed

```sh
kubectl auth can-i create resourcequotas \
  --as=system:serviceaccount:kyverno:kyverno-background-controller
```
Expect `yes`.

---

## Step 4: Confirm the Fix Works Going Forward

```sh
kubectl create namespace checkout-svc
kubectl get resourcequota default-quota -n checkout-svc -o yaml
```
The `default-quota` ResourceQuota should now exist in `checkout-svc` with `spec.hard.pods: "10"`.

---

## Step 5: Verify Your Configuration

```sh
kubectl get clusterrole kyverno-generate-resourcequota -o yaml
kubectl get resourcequota default-quota -n checkout-svc
```
Once verified, run the local validation suite to pass the lab!
