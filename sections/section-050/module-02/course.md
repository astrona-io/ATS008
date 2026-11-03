# Sizing, Disruption Budgets and Spreading Replicas

Running more than one replica is only the start of a highly available Kyverno. The ships must be big enough for their job. The scheduler must not take too many of them away at once. And the ships should not all sit at one dock.

A node drain is the test. When an administrator empties a space dock for maintenance, Kubernetes evicts its Pods one by one. Whether Kyverno keeps answering launch requests during that time depends on three things you set in the Helm values: the replica count and sizes, the PodDisruptionBudget and the spread rules.

This module shows which values control each of them, checked against the chart's own values file and `helm template`.

## How this module is organised

1. **Sizing Replicas and Resources** shows the replica and resource keys per controller, the chart defaults and what Kyverno's scaling guidance says.
2. **Leases and What a Node Drain Does** reads the leases and explains eviction, with a Pod deleted to show a lease change hands.
3. **Disruption Budgets and Spreading Replicas** sets a PodDisruptionBudget, topology spread constraints and a priority class, and checks them on the live objects.

## Learning objectives

After this module you can:

- Name the values that set replicas and resources for each of the four controllers.
- Say which chart defaults apply to replicas, resource requests and limits.
- Set a PodDisruptionBudget with `minAvailable` or `maxUnavailable`, and say why you cannot set both.
- Add `topologySpreadConstraints` and say how they differ from the chart's default anti-affinity.
- Read a lease holder with `kubectl get lease -n kyverno` and say what happens to a lease when its holder is evicted.
- Prove the settings on the live Deployments and PodDisruptionBudgets, and say what a one-node cluster cannot prove.

## Before you start

You need to know that each Kyverno controller is its own Deployment, and that `helm upgrade` applies a values file. You also need to know what leader election is: one replica holds a lease and does the work while the others stand by.

## Where you practise

Your playground is a single-node `kind` cluster, a training solar system with one space dock. Kyverno is already installed with Helm at default values, with one replica per controller. You refit it with `helm upgrade`. Launch the playground now and keep it next to you while you read the parts:

<!-- astrona:playground -->
