# Summary

Kyverno is four controllers, and a replica means something different for each. This module showed what each replica buys, how to order them, and what a one-node cluster can prove.

## What you learned

### Why Replicas Behave Differently Per Controller

The admission controller answers AdmissionReview signals from every replica, with no leader election for that traffic. Three replicas is the documented minimum for a highly available one. The background and reports controllers use leader election for their work, so extra replicas only add failover. The cleanup controller mixes both models. See [Why Replicas Behave Differently Per Controller](./course-01-why-replicas-behave-differently.md).

### Installing for HA with Helm

One `helm install` sets a count per controller (`admissionController.replicas=3` and `2` for the other three). A Lease names its holder in `holderIdentity`. The chart adds a PodDisruptionBudget when a controller has more than one replica, and a soft `podAntiAffinity` on `kubernetes.io/hostname`. It does not set `topologySpreadConstraints`. A one-node cluster shows every Pod on the same node, so it cannot prove spreading. See [Installing for HA with Helm](./course-02-installing-for-ha-with-helm.md).

## Missions

| Mission | What it asks | Lab name |
| --- | --- | --- |
| Running Kyverno Highly Available Lab | Install with 3/2/2/2 replicas, find the background lease holder, confirm three admission Pods | `ats-008-lab-009` |

## Check yourself

- Which controller can use all its replicas at the same time for live traffic?
- Why does `backgroundController.replicas=5` not scan faster?
- What does `holderIdentity` tell you?
- What does the chart's anti-affinity do, and why does it prove nothing on one node?

Clean up the playground. List what is running, then destroy the playground:

```sh
astrona list
astrona destroy ats-008-playground-050-01
```

<!-- astrona:playground:destroy -->
