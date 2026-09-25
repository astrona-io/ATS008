# Part 1 — Why Replicas Behave Differently Per Controller

> Prerequisite: [Landing page](./course.md). Next: [Part 2 — Installing for HA with Helm](./course-02-installing-for-ha-with-helm.md).

## The admission controller: horizontal scaling, no leader election for traffic

The admission controller is the one Kyverno process sitting directly in the request path of every write to the cluster — every `kubectl apply`, every controller reconcile loop that creates or updates an object passes through its webhook first. Kyverno's own documentation is explicit about how it scales: **"The admission controller does not use leader election for inbound webhook requests, which means AdmissionReview requests can be distributed and processed by all available replicas."**

That means three admission-controller replicas genuinely triples your request-handling capacity. Kubernetes' own Service load-balances incoming webhook calls across whichever replicas are Ready, and every one of them independently evaluates policies and returns an admission decision. There is no single "chosen" replica doing the real work while the others idle.

Kyverno's documented benchmarks back this up under load. With 500 concurrent virtual users hammering the cluster:

- A single admission-controller replica saw **p99 latency exceed 1 second**.
- Three replicas kept **every scenario under 650ms p99**.
- Three replicas also **cut peak CPU usage per pod from roughly 3033m down to roughly 1182m** under the same extreme load — spreading work across replicas didn't just help latency, it kept any single Pod from being pinned at the CPU limit.

Because of this, Kyverno's own guidance recommends a **minimum of 3 replicas** for the admission controller in any production installation.

The one exception: the admission controller *does* use leader election internally, but only for a secondary, low-frequency job — managing its own TLS certificates and keeping the cluster's webhook configurations up to date. That work only needs one replica doing it at a time; it has nothing to do with how many replicas can serve live traffic.

> [!TIP]
> **Try it — see the elected leader**
>
> Once Kyverno is installed:
> ```sh
> kubectl get lease -n kyverno
> ```
> You'll see one or more `Lease` objects — Kubernetes' standard leader-election primitive. Each lease's `holderIdentity` names the Pod currently acting as leader for that piece of work.

## The background and reports controllers: leader election for the real work

The background controller and the reports controller are built the opposite way. Their entire job — periodically re-scanning existing resources against policies, aggregating results into `PolicyReport`/`ClusterPolicyReport`, and finishing `generate`/mutate-existing operations — is inherently stateful and sequential. Running it from multiple replicas at once would mean duplicate work and race conditions, not more throughput.

So Kyverno uses Kubernetes leader election here too, but for the *entire* job, not just certificate housekeeping: **"only a single replica will handle reports processing at any given time"** for the reports controller, and **"only a single replica of the background controller will handle the final resource generation"** for the background controller. Every other replica sits idle, watching the `Lease`, ready to take over the instant the current leader stops renewing it.

This means running `backgroundController.replicas: 5` does not scan resources five times faster. It gives you faster failover if the current leader Pod dies — nothing more.

> [!WARNING]
> **Common pitfall**
>
> Assuming `backgroundController.replicas` (or `reportsController.replicas`) is a throughput knob. It is not. If background scans are genuinely too slow, the fix is tuning that controller's own concurrency flags (`--genWorkers`, `--backgroundScanWorkers` — covered in Section 030), not adding replicas. Extra replicas of a leader-elected controller only buy you resilience to a Pod or node failure.

## The cleanup controller: a hybrid of both models

The cleanup controller doesn't fit neatly into either bucket. Like the admission controller, it has a piece that needs leader election — certificate and webhook-configuration management, the same housekeeping job. But its actual cleanup-handling logic "supports both availability and scale for cleanup invocations," since individual scheduled deletions are dispatched as their own Kubernetes CronJobs rather than being processed serially by a single elected leader.

The practical takeaway: don't assume every Kyverno controller behaves like the admission controller, and don't assume every controller behaves like the background controller either. Each one's scaling story has to be checked on its own terms.

## Reference

- Kyverno's high-availability documentation — the authoritative source for leader-election behavior per controller.
- Kyverno's scaling/performance documentation — the source of the p99 latency and CPU figures cited above.
- `kubectl explain lease` — the Kubernetes API shape behind leader election.
