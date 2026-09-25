# Part 2 — Installing for HA with Helm

> Prerequisite: [Part 1 — Why Replicas Behave Differently Per Controller](./course-01-why-replicas-behave-differently.md). Next: [Section 060 — Upgrading Kyverno](../../section-060/module-01/course.md).

## The documented production install command

Kyverno's own installation documentation gives a specific, ready-to-use command for a highly-available production install:

```sh
helm install kyverno kyverno/kyverno -n kyverno --create-namespace \
  --set admissionController.replicas=3 \
  --set backgroundController.replicas=2 \
  --set cleanupController.replicas=2 \
  --set reportsController.replicas=2
```

Notice the asymmetry, which is exactly the lesson from Part 1: the admission controller gets **3** replicas because every one of them can serve live traffic, giving real throughput and resilience. The background, cleanup, and reports controllers each get **2** — enough that a leader failure has an immediate standby to take over, but no more, because a third or fourth replica of a leader-elected controller would just sit idle.

> [!TIP]
> **Try it — see where replicas landed**
>
> ```sh
> kubectl get pods -n kyverno -o wide
> ```
> The `NODE` column shows which node each Pod is scheduled on. In a real multi-node cluster, having every replica of a controller name the same node defeats the point of running more than one — a node failure would still take the whole controller down.

## Spreading replicas across nodes

Kyverno's docs focus on replica *counts*, not scheduling constraints — so this part is general Kubernetes HA hygiene, not a Kyverno-specific documented default. If you want the availability guarantee those replica counts imply to actually hold under a node failure, pair them with either:

- A `podAntiAffinity` rule that discourages (or forbids) scheduling two replicas of the same Kyverno Deployment onto the same node, or
- A `topologySpreadConstraints` entry that spreads replicas evenly across nodes (and, in a multi-zone cluster, across zones).

Neither is set for you automatically just because you asked for 3 replicas — Kubernetes is free to place all 3 on the same node unless you tell it not to. This is standard practice for any HA-critical Deployment, not something unique to Kyverno.

> [!WARNING]
> **Common pitfall**
>
> Treating a high replica count as a substitute for anti-affinity. Three admission-controller replicas that all happen to land on the same node give you *zero* additional resilience to a node failure — you've spent the extra CPU/memory for nothing if that one node goes down.

## Reference

- Kyverno's installation documentation — the source of the documented HA install command above.
- Kubernetes `podAntiAffinity` / `topologySpreadConstraints` documentation — standard mechanisms for spreading replicas, applicable to any Deployment.
