# The Time-to-Live Label

Sometimes you do not want a schedule for a whole group of ships. You want one ship to carry its own expiry date, like a food label on a ration pack. Kyverno supports this with one label: `cleanup.kyverno.io/ttl`. The label needs no policy at all. TTL stands for time to live: how long the object may live.

## One real example

Make a ConfigMap and stamp it with a two-minute life:

<!-- astrona:playground:renew -->

```sh
kubectl create configmap short-lived -n docking-bay --from-literal=note=temporary
kubectl label configmap short-lived -n docking-bay cleanup.kyverno.io/ttl=2m
```

The cleanup controller removes the ConfigMap after about two minutes. The next sections explain what happens and what could stop it.

## How the label works

The value of the label is either a duration, such as `2m`, `5h` or `1d`, or a fixed date and time, such as `2026-12-01T00:00:00Z`. With a duration, the countdown starts at the moment the object was created. The label works on any kind that the cleanup controller may delete.

Which part does the work? The cleanup controller. A part of it, the TTL controller, wakes up on a fixed interval and looks for labelled objects whose time has passed. The default interval is one minute. In the chart it is the value `ttlController.reconciliationInterval`, which the chart turns into the flag `--ttlReconciliationInterval=1m` on the cleanup controller. So an object can live up to one interval longer than its label says.

Check the flag on your cluster:

```sh
kubectl get deployment kyverno-cleanup-controller -n kyverno -o jsonpath='{.spec.template.spec.containers[0].args}'
```

Look for `--ttlReconciliationInterval=1m` in the list.

## Permission is still needed

The label does not skip clearance. The salvage crew must be allowed to `delete` the kind, just as for a policy. Test it for ConfigMaps:

```sh
kubectl auth can-i delete configmaps -n docking-bay --as=system:serviceaccount:kyverno:kyverno-cleanup-controller
```

If the answer is `no`, the label does nothing. The fix is a `ClusterRole` that allows `delete` on `configmaps` and carries the label `rbac.kyverno.io/aggregate-to-cleanup-controller: "true"`. Kyverno's master clearance card for the crew then includes it.

Wait three minutes and look again:

```sh
kubectl get configmap -n docking-bay
```

If the crew has clearance, `short-lived` is gone and the other ConfigMaps are still there. If you have no clearance yet, it is still there. Both results teach the same rule: a label only asks for a deletion, and the permission decides if it happens.

## Common pitfalls

> [!WARNING]
> - **Expecting the object to vanish at the exact second.** The check runs on an interval, one minute by default.
> - **Forgetting permission.** The label alone cannot delete a kind that the cleanup controller may not delete.
> - **A bad value.** A value that is neither a duration nor a date is not understood, and the object stays.
> - **Using the label on something you need.** There is no undo. The object is deleted for good.
