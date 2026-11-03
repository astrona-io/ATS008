# Summary

A highly available Kyverno needs more than a replica count. This module showed the values that size each controller, keep ships in the air during a node drain and spread them over docks, and how to prove each one on the live objects.

## What you learned

### Sizing Replicas and Resources

Each controller has a `replicas` key. The admission resources sit under `admissionController.container.resources`, and the other three controllers use `resources`. The chart leaves replicas empty (one ship), rejects zero, and sets memory limits but no CPU limit. Kyverno's guidance says to size admission memory for the number of policies, to add replicas for throughput and availability, to avoid CPU limits and to measure your own cluster. See [Sizing Replicas and Resources](./course-01-sizing-replicas-and-resources.md).

### Leases and What a Node Drain Does

A Lease is the captain's baton, and `holderIdentity` names the holder. A drain cordons a node and evicts its Pods. Eviction respects PodDisruptionBudgets and a `kubectl delete pod` does not. When a holder goes away, a standby takes the lease after it runs out. See [Leases and What a Node Drain Does](./course-02-leases-and-what-a-node-drain-does.md).

### Disruption Budgets and Spreading Replicas

A PodDisruptionBudget uses `minAvailable` or `maxUnavailable`, never both, and the chart creates one when a controller has more than one replica. The chart sets a soft anti-affinity but no `topologySpreadConstraints`. `priorityClassName` sets scheduling priority. A one-node cluster proves the settings exist, not that Pods spread. See [Disruption Budgets and Spreading Replicas](./course-03-disruption-budgets-and-spreading-replicas.md).

## Missions

| Mission | What it asks | Lab name |
| --- | --- | --- |
| Sizing and Spreading Kyverno Lab | Install with three admission replicas, a budget with one allowed disruption, a spread rule, a priority class and two background replicas | `ats-008-lab-019` |

## Check yourself

- Which key holds the admission controller's resource requests?
- Why does a drain respect a budget but `kubectl delete pod` does not?
- What error do you get if you set both `minAvailable` and `maxUnavailable`, and how do you avoid it?
- What can a one-node cluster not prove about `topologySpreadConstraints`?

Clean up the playground. List what is running, then destroy the playground:

```sh
astrona list
astrona destroy ats-008-playground-050-02
```

<!-- astrona:playground:destroy -->
