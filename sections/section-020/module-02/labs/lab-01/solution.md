# Solution Walkthrough

After each step you can run `astrona submit -c sections/section-020/module-02/labs/lab-01` to see which check passes. The three checks are in this order: the policy, the permission and the behaviour. The behaviour check needs both of the others.

---

## Step 1: Ask the clearance office

```sh
kubectl auth can-i delete configmaps -n salvage-yard --as=system:serviceaccount:kyverno:kyverno-cleanup-controller
```

The answer is `no`. The cleanup controller has no clearance for ConfigMaps yet.

---

## Step 2: Give the cleanup controller clearance

Save this as `clusterrole-cleanup-configmaps.yaml`:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: cleanup-configmaps
  labels:
    rbac.kyverno.io/aggregate-to-cleanup-controller: "true"
rules:
  - apiGroups:
      - ""
    resources:
      - configmaps
    verbs:
      - get
      - list
      - watch
      - delete
```

Apply it:

```sh
kubectl apply -f clusterrole-cleanup-configmaps.yaml
```

Then check again. If the answer is still `no`, wait a few seconds and run it again:

```sh
kubectl auth can-i delete configmaps -n salvage-yard --as=system:serviceaccount:kyverno:kyverno-cleanup-controller
```

Run `astrona submit`. The permission check should pass now. The policy check should still fail.

---

## Step 3: Write the salvage schedule

Save this as `cleanuppolicy-remove-scrap.yaml`:

```yaml
apiVersion: kyverno.io/v2
kind: CleanupPolicy
metadata:
  name: remove-scrap
  namespace: salvage-yard
spec:
  match:
    any:
      - resources:
          kinds:
            - ConfigMap
          selector:
            matchLabels:
              scrap: "true"
  schedule: "* * * * *"
```

Apply it:

```sh
kubectl apply -f cleanuppolicy-remove-scrap.yaml
```

Run `astrona submit`. The policy check passes, and the behaviour check creates test ConfigMaps and waits for the labelled one to go.

---

## Step 4: Check that it ran

```sh
kubectl get cleanuppolicies.kyverno.io remove-scrap -n salvage-yard -o jsonpath='{.status.lastExecutionTime}'
kubectl logs -n kyverno deployment/kyverno-cleanup-controller --tail=30
```

A time stamp in the first command means the crew has run the schedule. If the behaviour check fails, look at the permission first, then at the label in `match`, then at the schedule.
