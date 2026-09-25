# Part 2 — Reporting & State CRDs

> Prerequisite: [Part 1 — Policy-Authoring CRDs](./course-01-policy-authoring-crds.md). Next: [Section 030 — Controller Configuration with Flags](../../section-030/module-01/course.md).

Every CRD in Part 1 is something you write. Everything in this part is something Kyverno writes *for* you, as a direct consequence of admission requests and background scans. Reading these correctly is how you answer "is this policy actually catching anything?" without guessing.

## PolicyReport and ClusterPolicyReport — the results you actually read

`PolicyReport` (namespaced) and `ClusterPolicyReport` (cluster-scoped), both `apiVersion: wgpolicyk8s.io/v1alpha2` (a shared, cross-vendor policy-reporting standard, not a Kyverno-specific API group), are the aggregated, human-facing results:

```sh
kubectl get policyreport -n checkout
kubectl get clusterpolicyreport
```

Each entry summarizes pass/fail counts per policy against real resources in that scope — this is the object you point a dashboard, a CI gate, or your own eyeballs at when you want to know Kyverno's actual verdict on the cluster's current state.

## AdmissionReport, BackgroundScanReport, and friends — internal plumbing

`AdmissionReport`/`ClusterAdmissionReport` and `BackgroundScanReport`/`ClusterBackgroundScanReport` (all `apiVersion: kyverno.io/v1alpha2`) are intermediary objects: one is created per admission request or per background-scan pass, then merged upward by the reports-controller into the `PolicyReport`/`ClusterPolicyReport` objects above. They are not meant for direct consumption — treat them as implementation detail, the way you would a controller's internal work queue.

> [!TIP]
> **Try it — watch the ephemeral intermediaries**
>
> ```sh
> kubectl get admissionreport -A
> kubectl get backgroundscanreport -A
> ```
>
> Expect a churn of short-lived objects, especially right after applying a new policy or creating a batch of resources — this is the reports-controller's raw material, being continuously consumed and merged into the stable `PolicyReport` objects a moment later.

## UpdateRequest — the background-controller's work queue

`UpdateRequest` (`apiVersion: kyverno.io/v1beta1`, namespaced) is the internal queue Kyverno uses to track pending `generate`/mutate-existing work that the background-controller still needs to reconcile — for example, a `generate` rule's target resource that has drifted and needs to be re-synchronized. Like the report intermediaries above, you will occasionally inspect it while debugging a generate rule that "isn't catching up," but you never author one by hand.

## Seeing the whole surface at once

The fastest way to stop guessing which CRD you need is to just list everything Kyverno registered:

> [!TIP]
> **Try it — enumerate every Kyverno CRD**
>
> ```sh
> kubectl get crd | grep kyverno.io
> kubectl api-resources | grep -i kyverno
> ```
>
> The first command lists CRD objects by name (including the `wgpolicyk8s.io` report CRDs will *not* show up here, since they are a different API group — grep for `policyreport`/`report` separately if you want those too). The second lists every API resource Kyverno contributes, alongside its short name, `APIVERSION`, and whether it is namespaced — the fastest single-command way to confirm exactly what surface a given Kyverno version installed.

> [!WARNING]
> **Common pitfall**
>
> Debugging "my policy isn't working" by staring at `AdmissionReport` objects instead of `PolicyReport`/`ClusterPolicyReport`. The former is high-churn internal state that can look empty or inconsistent between polling intervals purely because it was already merged and cleaned up — the latter is the stable, intended read surface. If you need a durable answer, read the report CRD, not the intermediary.

## Reference

- `kubectl explain policyreport` / `kubectl explain clusterpolicyreport` — live schema for the `wgpolicyk8s.io` report objects.
- `kubectl api-resources | grep -i kyverno` — the complete, version-accurate list of every resource Kyverno's CRDs contribute.
