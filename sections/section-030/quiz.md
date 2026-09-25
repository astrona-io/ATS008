# Section 030 Knowledge Check: Controller Configuration with Flags

Test your understanding of Kyverno's four controllers, their individual flags, the extraArgs Helm nesting pattern, and the ConfigMap-vs-flag distinction.

---

## Scenario-Based Questions

### Question 1
Generated resources from `generate` rules are appearing noticeably later than you'd like under heavy load. Which controller and which flag should you look at first?
*   **A)** The admission controller's `--webhookTimeout`.
*   **B)** The background controller's `--genWorkers`, which controls concurrency for generate-rule processing.
*   **C)** The reports controller's `--backgroundScanInterval`.
*   **D)** The cleanup controller's `--ttlReconciliationInterval`.

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: B**

*   **Why B is correct:** `generate` rules are processed asynchronously by the background controller, and `--genWorkers` (default `10`) directly controls how many of those generate operations it processes concurrently. Raising it increases throughput for a backlog of pending generate work.
*   **Why others are incorrect:**
    *   *Option A* controls how long the admission controller waits for a webhook response during live admission — unrelated to asynchronous generate processing.
    *   *Option C* controls how often existing resources are re-scanned for reporting, not how fast generate operations complete.
    *   *Option D* controls the cleanup controller's scheduled-deletion reconciliation, a completely different job.
</details>

---

### Question 2
Which controller and flag control how often Kyverno re-scans already-existing resources to refresh `PolicyReport`/`ClusterPolicyReport` entries?
*   **A)** The background controller's `--genWorkers`.
*   **B)** The admission controller's `--maxAuditWorkers`.
*   **C)** The reports controller's `--backgroundScanInterval` (default `1h`).
*   **D)** The cleanup controller's `--cleanupServerPort`.

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: C**

*   **Why C is correct:** The reports controller owns background scanning and report aggregation; `--backgroundScanInterval` sets how frequently it re-evaluates existing resources against active policies, feeding fresh results into `PolicyReport`/`ClusterPolicyReport`.
*   **Why others are incorrect:**
    *   *Option A* is the background controller's generate-concurrency flag, unrelated to scanning cadence.
    *   *Option B* tunes audit-mode admission-time processing capacity, not periodic re-scanning of existing resources.
    *   *Option D* is just the cleanup controller's webhook server port, unrelated to reporting.
</details>

---

### Question 3
You write a Helm values file setting `admissionController.extraArgs: ["--webhookTimeout=15"]` (no `.container.` in the path) and `backgroundController.container.extraArgs: ["--genWorkers=5"]` (with a `.container.` you added by habit). After `helm upgrade`, neither flag appears on its target Deployment. Why?
*   **A)** Both flags are misspelled.
*   **B)** You have the nesting backwards for both: the admission controller's extraArgs key needs `.container.` (`admissionController.container.extraArgs`), while the background controller's does not (`backgroundController.extraArgs`) — as written, both values sit in parts of the values tree Kyverno's chart templates never read.
*   **C)** `helm upgrade` requires `--force` to apply new `extraArgs` values.
*   **D)** `extraArgs` values only take effect on a fresh `helm install`, never on `helm upgrade`.

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: B**

*   **Why B is correct:** The nesting is inconsistent by design in the chart: the admission controller's extra-args value is `admissionController.container.extraArgs`, but the other three controllers (background, reports, cleanup) use a flat `<controller>.extraArgs` with no `.container.` level. Swapping the two patterns, as this question does, puts both values where the chart's templates never look, so neither flag reaches its container.
*   **Why others are incorrect:**
    *   *Option A* — the flag strings themselves are fine; the problem is the values-tree location, not spelling.
    *   *Option C* — no such requirement exists; a normal `helm upgrade` applies new `extraArgs` values.
    *   *Option D* — `extraArgs` is a normal values key and works identically on `helm install` or `helm upgrade`.
</details>

---

### Question 4
You need to confirm exactly which flags the `kyverno-reports-controller` Deployment is actually running with right now, not what a values file *should* have set. What is the most direct way to check?
*   **A)** `helm get values kyverno -n kyverno`, since installed values always match the live Pod exactly.
*   **B)** `kubectl get deploy kyverno-reports-controller -n kyverno -o jsonpath='{.spec.template.spec.containers[0].args}'`.
*   **C)** `kubectl get configmap kyverno -n kyverno -o yaml`.
*   **D)** `kubectl logs -n kyverno -l app.kubernetes.io/component=reports-controller`, since flags are always echoed to stdout at startup.

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: B**

*   **Why B is correct:** The Deployment's `.spec.template.spec.containers[0].args` is the authoritative, live list of arguments the container is actually running with — reading it directly confirms reality regardless of what any values file intended.
*   **Why others are incorrect:**
    *   *Option A* shows the Helm release's recorded values, which can drift from what actually templated into the Deployment if there was a values-path mistake (exactly the failure mode in Question 3) — it is not a substitute for checking the Deployment itself.
    *   *Option C* is the ConfigMap, a different mechanism entirely from container flags.
    *   *Option D* is not guaranteed and is far more indirect than simply reading the Deployment spec.
</details>

---

### Question 5
You update `config.excludeUsernames` in a Helm values file and re-apply it. Compare that to updating `backgroundController.extraArgs` and re-applying it. What is the key operational difference?
*   **A)** There is no difference — both always require every Kyverno Pod to restart.
*   **B)** `config.*` settings live in Kyverno's ConfigMap and are often picked up live without a restart, while a container-flag change under `extraArgs` always requires that controller's Pods to roll before it takes effect.
*   **C)** `extraArgs` changes are hot-reloaded, while ConfigMap changes always require a full Helm uninstall/reinstall.
*   **D)** Both are ignored unless you also pass `--recreate-pods` to `helm upgrade`.

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: B**

*   **Why B is correct:** `config.*` values are written into Kyverno's ConfigMap, which Kyverno watches and reloads many settings from live. A container flag, by contrast, is baked into the Pod spec at the moment the Pod starts — changing it only takes effect once the Deployment rolls new Pods with the new `args`.
*   **Why others are incorrect:**
    *   *Option A* ignores the real distinction the question is testing.
    *   *Option C* reverses the actual behavior.
    *   *Option D* invents an unnecessary flag; a normal `helm upgrade` rollout handles both cases correctly (immediately for many ConfigMap settings, after a rollout for flags).
</details>

---

### Question 6
You lower the admission controller's `--webhookTimeout` from its default of `10` seconds down to `3`. What is the most likely operational consequence under real load?
*   **A)** No effect — `--webhookTimeout` only applies to `mutate` rules, never `validate` rules.
*   **B)** Requests that take longer than 3 seconds for Kyverno to evaluate are more likely to time out at the webhook, and depending on `failurePolicy`, either fail open or be rejected — a shorter timeout trades safety margin for a faster worst-case failure signal.
*   **C)** The change is silently ignored; `--webhookTimeout` cannot go below the Kubernetes API server's own default of 10 seconds.
*   **D)** It only affects how long `kubectl apply` waits for a response locally, not the actual webhook call.

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: B**

*   **Why B is correct:** `--webhookTimeout` bounds how long the admission controller has to respond to an AdmissionReview call before the API server treats the webhook as having failed. Shrinking it increases the chance that a legitimately slower evaluation (e.g. a rule with an external `context` API call) misses the window, and the outcome from there depends on the webhook's `failurePolicy` (`Fail` vs `Ignore`).
*   **Why others are incorrect:**
    *   *Option A* is wrong — the timeout applies to the webhook call generally, not to one specific rule action type.
    *   *Option C* invents a floor that does not exist; Kyverno's own documented range is 1-30 seconds.
    *   *Option D* misunderstands the mechanism — the timeout governs the API server's wait on the actual webhook HTTP call, not any local client behavior.
</details>

---

### Question 7
What does `--clientRateLimitQPS`/`--clientRateLimitBurst` (shared across all four controllers, default `300`/`300`) actually protect?
*   **A)** It limits how many `kubectl apply` commands a human operator can run per second.
*   **B)** It limits how many API requests a Kyverno controller itself makes to the Kubernetes API server per second, protecting the API server from being overwhelmed by Kyverno's own traffic.
*   **C)** It limits how many Pods can be admitted per second cluster-wide.
*   **D)** It limits how many `PolicyReport` objects can exist at once.

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: B**

*   **Why B is correct:** These flags configure the client-side rate limiter each Kyverno controller uses for its own calls out to the Kubernetes API server (watches, gets, creates, updates) — a safeguard so a busy controller, particularly under heavy background scanning or generate load, doesn't itself become a source of API server overload.
*   **Why others are incorrect:**
    *   *Option A* — these flags configure Kyverno's own controllers, not any human tooling.
    *   *Option C* — admission throughput is governed by the webhook path and cluster capacity generally, not this specific rate limiter.
    *   *Option D* — there is no such object-count cap; this is purely about API call rate.
</details>
