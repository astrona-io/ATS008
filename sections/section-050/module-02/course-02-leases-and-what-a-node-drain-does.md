# Leases and What a Node Drain Does

A leader-elected controller is only safe if a standby can take over. This part reads the leases that make that happen, then explains what a node drain does to a Pod, and why deleting a Pod is not the same as draining its node.

## Reading a lease

A **Lease** is a small Kubernetes object that works as the captain's baton. The holder writes its own name into `spec.holderIdentity` and renews the lease from time to time. A standby watches it. If the holder stops renewing, the lease runs out and a standby takes it.

Kyverno keeps its leases in its own namespace. You do not need to know their names by heart. List them and read the holder column.

## What a node drain does

A **node drain** empties a space dock before maintenance. First the node is marked unschedulable (a **cordon**), so no new ships dock there. Then each Pod on it is evicted. An **eviction** is a polite request to the API server to remove a Pod. The server refuses the request if it would break a PodDisruptionBudget, and the drain then waits and tries again.

Two facts matter for Kyverno:

- Eviction respects PodDisruptionBudgets. A plain `kubectl delete pod` does not. It removes the Pod at once, whatever the budget says.
- When an evicted Pod holds a lease, a standby takes the baton after the lease runs out. For a short time nobody holds it. That is acceptable for the background and reports controllers, because their work is not in the path of every request. The admission controller does not depend on a lease for requests, so the other replicas keep answering.

Your playground has one node, so you will not drain it. A drain would evict every Pod on the only dock, including the cluster's own services. You will delete the lease holder's Pod instead. That shows the lease changing hands, but it does not test a budget.

## See it in your playground

You need two background replicas, so that one can stand by. Raise the count and keep your other values:

<!-- astrona:playground:renew -->

```sh
helm upgrade kyverno kyverno/kyverno -n kyverno --reuse-values --set backgroundController.replicas=2
kubectl -n kyverno rollout status deployment/kyverno-background-controller --timeout=180s
```

Now list the leases and their holders:

```sh
kubectl get lease -n kyverno -o custom-columns=NAME:.metadata.name,HOLDER:.spec.holderIdentity
```

Each row is one baton. The holder column holds the name of a Pod. Find the row whose holder is a background controller Pod, then list those Pods:

```sh
kubectl get pods -n kyverno -l app.kubernetes.io/component=background-controller
```

One of the two Pods is the holder. Delete it, replacing the name with the holder you found:

```sh
kubectl delete pod <holder-pod-name> -n kyverno
```

Run the lease listing again a few times, for example with a short wait between runs:

```sh
kubectl get lease -n kyverno -o custom-columns=NAME:.metadata.name,HOLDER:.spec.holderIdentity
```

The holder of that lease changes to the standby Pod or to the new Pod that the Deployment created. Right after the delete it may still show the old name until the lease runs out. If it does not change at first, wait and run it again.

## Common pitfalls

> [!WARNING]
> - **Testing a PodDisruptionBudget with `kubectl delete pod`.** A delete ignores budgets. Only evictions, such as a node drain, respect them.
> - **Draining the only node of a training cluster.** It evicts every Pod on the dock, so do not do it here.
> - **Expecting an instant change of captain.** The standby waits until the old lease runs out. For a moment there is no holder.
> - **Reading a lease name and assuming it is the Pod name.** The lease name is the baton. The Pod is in `holderIdentity`.
