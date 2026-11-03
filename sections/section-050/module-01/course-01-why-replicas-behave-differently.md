# Why Replicas Behave Differently Per Controller

Kyverno has four controllers, and a replica count means something different for each. This part explains the three models, so you know what extra ships buy you before you order them.

## The admission controller: every replica answers

The admission controller sits in the path of every launch request. Each `kubectl apply` goes through the registry desk (the API server), and the desk calls Kyverno's webhook before it accepts the request. Kyverno's documentation says the admission controller does not use leader election for inbound webhook requests, so every available replica can process AdmissionReview requests.

An **AdmissionReview** is the signal the registry desk sends to an inspector: "may I accept this?" A Kubernetes Service spreads these signals over all ready replicas. Three replicas share the load and keep answering when one is restarted. The documentation says the minimum supported replica count for a highly available admission controller is three.

One more fact: more replicas share the load, but they do not split the rule book. Every replica holds all the policies. So the memory each replica needs depends on how many policies you have, not on how many replicas you run.

The admission controller does use leader election for one small job: managing its certificates and the webhook configurations. Only one replica needs to do that at a time. It has nothing to do with who may answer live traffic.

## The background and reports controllers: one captain

The background controller (the construction crew) and the reports controller (the records office) work the other way. Their work is one ordered job. Two replicas doing it at once would duplicate work or collide. So Kyverno uses leader election for the whole job. The documentation says the extra replicas of these two controllers can only be used for availability.

A **Lease** is the Kubernetes object used for leader election. Think of it as the captain's baton. The `holderIdentity` field names the Pod that holds it. The other replicas stand by and watch the baton. If the captain stops renewing the lease, a standby takes it.

So `backgroundController.replicas=5` does not scan five times faster. It gives you faster recovery if the captain's ship fails. If scans are too slow, you tune the crew's own dials (flags such as `--backgroundScanWorkers`), not the replica count.

## The cleanup controller: a mix

The cleanup controller has both a leader-elected part and a part that is not. Certificate and webhook management uses leader election. The documentation says the cleanup handler itself does not, and that extra replicas can serve both availability and scale for cleanup. So do not copy the admission model or the background model onto it. Check each crew on its own.

| Controller | Who does the work | What an extra replica buys |
| --- | --- | --- |
| Admission | Every replica, at the same time | Throughput and availability |
| Background | The lease holder only | Availability |
| Reports | The lease holder only | Availability |
| Cleanup | A mix of both models | Availability and scale for cleanup |

## See it in your playground

Kyverno is not installed yet, but you can already ask the chart what it would create. The chart is the station kit, and `helm template` prints the plan without building anything.

<!-- astrona:playground:renew -->

Print the replica lines the chart renders when you give it no replica values:

```sh
helm template kyverno kyverno/kyverno -n kyverno | grep -n "^  replicas:"
```

You should see four `replicas:` lines with nothing after them. The chart leaves the value empty, and Kubernetes then runs one ship per Deployment. Now give the admission controller three replicas and look again:

```sh
helm template kyverno kyverno/kyverno -n kyverno --set admissionController.replicas=3 | grep -n "^  replicas:"
```

One of the four lines now reads `replicas: 3`. The chart sets the count for exactly the controller you named.

## Common pitfalls

> [!WARNING]
> - **Treating `backgroundController.replicas` or `reportsController.replicas` as a speed knob.** Only the lease holder works. Extra replicas buy failover only.
> - **Running one admission replica in production.** One restart or one node failure leaves the registry desk calling a webhook that does not answer.
> - **Copying one controller's replica count to the others.** Each controller has its own model, so check what a replica buys before you pay for it.
