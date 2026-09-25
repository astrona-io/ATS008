# Part 1 — The Four Controllers & Their Flags

> Prerequisite: [Landing page](./course.md). Next: [Part 2 — Setting Flags via Helm](./course-02-setting-flags-via-helm.md).

## One install, four binaries

A default Kyverno install creates four Deployments in the `kyverno` namespace:

```sh
kubectl get deploy -n kyverno
```

```text
NAME                          READY   UP-TO-DATE   AVAILABLE   AGE
kyverno-admission-controller  1/1     1            1           2m
kyverno-background-controller 1/1     1            1           2m
kyverno-reports-controller    1/1     1            1           2m
kyverno-cleanup-controller    1/1     1            1           2m
```

Each of these is a separately-built binary with its own container `args`. There is no single "Kyverno flags" list — there are four, and a flag that exists on one controller may not exist at all on another.

## The four controllers and their key flags

| Controller | Job | Key flags |
| --- | --- | --- |
| **admission** | Serves the AdmissionReview webhook for every matching create/update/delete request | `--webhookServerPort` (default `9443`), `--webhookTimeout` (default `10`s, range 1-30), `--webhookRegistrationTimeout` (default `120s`), `--autoUpdateWebhooks` (default `true`), `--maxAuditWorkers` (default `8`), `--maxAuditCapacity` (default `1000`), `--enablePolicyException` / `--exceptionNamespace` (PolicyException support — see Section 020), `--tlsKeyAlgorithm` (default `RSA`) |
| **background** | Processes `generate`/mutate-existing work asynchronously | `--genWorkers` (default `10`) — concurrency for generate-rule processing |
| **reports** | Runs periodic background scans and aggregates results into `PolicyReport`/`ClusterPolicyReport` | `--backgroundScan` (default `true`), `--backgroundScanInterval` (default `1h`), `--backgroundScanWorkers` (default `2`), `--aggregationWorkers` (default `10`), `--skipResourceFilters` (default `true`) |
| **cleanup** | Executes `CleanupPolicy`/`ClusterCleanupPolicy` scheduled deletions | `--cleanupServerPort` (default `9443`), `--ttlReconciliationInterval` (default `1m`) |

All four also share a small set of common flags: `--clientRateLimitQPS`/`--clientRateLimitBurst` (default `300`/`300`, protecting the Kubernetes API server from burst traffic each controller might generate), `--v` (log verbosity, `1`-`6`, default `2`), and `--loggingFormat` (`text` or `json`).

> [!TIP]
> **Try it — read a controller's live flags**
>
> ```sh
> kubectl get deploy kyverno-admission-controller -n kyverno \
>   -o jsonpath='{.spec.template.spec.containers[0].args}'
> ```
>
> Run the same command against `kyverno-background-controller`, `kyverno-reports-controller`, and `kyverno-cleanup-controller` (just swap the Deployment name). You will see four different argument lists — this is the fastest way to confirm exactly what a controller is running with, instead of trusting stale documentation or a values file you're not sure was actually applied.

## Reasoning about which controller owns a symptom

Because the four controllers are independent, a slow admission webhook and a stale `PolicyReport` are two unrelated problems with two unrelated fixes:

- Pods taking too long to admit? That's the **admission** controller — look at `--webhookTimeout` and `--maxAuditWorkers`.
- Generated resources appearing late? That's the **background** controller — look at `--genWorkers`.
- `PolicyReport` entries lagging behind reality? That's the **reports** controller — look at `--backgroundScanInterval`.
- Expired resources not being deleted on schedule? That's the **cleanup** controller — look at `--ttlReconciliationInterval`.

> [!WARNING]
> **Common pitfall**
>
> Assuming all four controllers share one flag set, so a flag that works on the admission controller (like `--maxAuditWorkers`) must also be valid on the background controller. It is not — each controller is a separate binary with its own flag parser, and passing an unrecognized flag to the wrong one will fail that controller's Pod at startup, not silently no-op.

## Reference

- `kubectl get deploy -n kyverno -o jsonpath='{.spec.template.spec.containers[0].args}'` (per controller) — the live, authoritative list of flags a controller is actually running with.
- Kyverno's Helm chart `values.yaml` — the canonical list of every flag exposed per controller for the installed chart version.
