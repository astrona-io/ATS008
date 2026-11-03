# Installing for HA with Helm

You know what a replica buys each controller. Now you order them. This part installs Kyverno with one replica count per controller, reads the leases, and looks honestly at what the chart does to spread the ships over docks, and what your one-node training cluster can and cannot show.

## One install, four replica counts

The command below installs the station with three admission replicas and two replicas for each of the other crews.

<!-- astrona:playground:renew -->

Run it in your playground:

```sh
helm install kyverno kyverno/kyverno -n kyverno --create-namespace \
  --set admissionController.replicas=3 \
  --set backgroundController.replicas=2 \
  --set cleanupController.replicas=2 \
  --set reportsController.replicas=2
```

Notice the difference. The admission controller gets three because the documented minimum for a highly available admission controller is three, and every one of them answers calls. The other three get two: one captain and one standby. A third standby of a crew that only lets one ship work would sit idle.

The chart refuses `replicas: 0` for any controller, because Kyverno does not support running with zero replicas.

Then wait for the four Deployments:

```sh
kubectl -n kyverno rollout status deployment/kyverno-admission-controller --timeout=180s
kubectl -n kyverno rollout status deployment/kyverno-background-controller --timeout=180s
kubectl -n kyverno rollout status deployment/kyverno-reports-controller --timeout=180s
kubectl -n kyverno rollout status deployment/kyverno-cleanup-controller --timeout=180s
```

Each command ends when that Deployment has all its replicas ready.

## See it in your playground

The Deployments show the count you asked for. The Leases show who holds each baton.

```sh
kubectl get deploy -n kyverno
kubectl get lease -n kyverno
```

The first command shows `3/3` for the admission controller and `2/2` for the other three. The second lists the Lease objects. Run this to see the holder name next to each lease:

```sh
kubectl get lease -n kyverno -o custom-columns=NAME:.metadata.name,HOLDER:.spec.holderIdentity
```

Each holder name is the name of one Pod. Compare it with `kubectl get pods -n kyverno`: the holder of a background lease is one of the two background Pods, and the other one is on standby.

## What the chart already does for availability

Replica counts are only half of availability. The chart also adds two things you did not ask for, and leaves one thing out. You can check all three with `helm template`.

- **A PodDisruptionBudget.** The chart creates one for a controller when its `podDisruptionBudget.enabled` is true or its replica count is above one. With the HA install, all four controllers get one, with `minAvailable: 1`. A **PodDisruptionBudget** is a rule that stops a voluntary eviction, such as a node drain, from taking away too many ships of one crew at once.
- **A soft anti-affinity rule.** Each Deployment carries a `preferredDuringSchedulingIgnoredDuringExecution` `podAntiAffinity` with `topologyKey: kubernetes.io/hostname`. It asks the scheduler to prefer docks that do not already hold a ship of the same crew. "Preferred" means the scheduler tries, but it will still park two ships at one dock if it has no other choice.
- **No topology spread constraints.** `topologySpreadConstraints` is an empty list by default. The chart does not set it for you.

Check the anti-affinity yourself on the live admission Deployment:

```sh
kubectl get deploy kyverno-admission-controller -n kyverno -o jsonpath='{.spec.template.spec.affinity.podAntiAffinity}'
```

You should see a `preferredDuringSchedulingIgnoredDuringExecution` entry for the label `app.kubernetes.io/component` with the value `admission-controller`.

## What a one-node cluster cannot show you

Your playground has one space dock. Run this:

```sh
kubectl get pods -n kyverno -o wide
```

The `NODE` column shows the same node for every Pod. That is expected, and it is the honest limit of this training solar system. The anti-affinity rule is only a preference, so the scheduler is free to put all three admission Pods on the one dock it has. A real multi-node cluster would try to place them on different docks, and you could see the spread in this column.

So here you can prove that the right objects exist: replica counts, Leases, the PodDisruptionBudget and the affinity block. You cannot prove that the Pods really landed on different nodes. On a real cluster you would check the `NODE` column too.

## Common pitfalls

> [!WARNING]
> - **Believing a high replica count survives a node failure on its own.** Three admission Pods on one node all die with that node. The chart's anti-affinity is only a preference.
> - **Saying "the chart sets nothing for spreading".** It sets a soft anti-affinity. It does not set topology spread constraints.
> - **Reading success from a one-node cluster.** All Pods on the same `NODE` is normal here. It proves nothing about spreading.
> - **Mixing up `kubectl get lease` with a list of Pods.** A Lease names the holder only. Read `holderIdentity`, then match it to a Pod.

## Your mission: Running Kyverno Highly Available Lab

You can now install Kyverno with a replica count per controller and read its leader-election state. The mission asks you to install Kyverno with the HA replica counts, wait for the four Deployments, find the holder of the background controller's lease and confirm three admission Pods.

Pause the playground first, so the lab has the memory it needs:

```sh
astrona stop ats-008-playground-050-01
```

Start the lab, then grade it when you are done:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS008.git -c sections/section-050/module-01/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS008.git -c sections/section-050/module-01/labs/lab-01
```

When you are done, remove the lab and start the playground again:

```sh
astrona destroy ats-008-lab-009
astrona start ats-008-playground-050-01
```
