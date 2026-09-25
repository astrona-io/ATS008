# Section 020 Knowledge Check: Kyverno Custom Resource Definitions (CRDs)

Test your understanding of the policy-authoring CRD family, PolicyException enablement, the reporting/state CRD family, and CRD discovery commands.

---

## Scenario-Based Questions

### Question 1
You author a syntactically valid `PolicyException` on a fresh, default Kyverno install and apply it with `kubectl apply -f`. The exempted resource is still blocked exactly as before. What is the most likely cause?
*   **A)** `PolicyException` objects take up to 24 hours to propagate.
*   **B)** `PolicyException` is disabled by default; it must be turned on with `--enablePolicyException=true` on the admission controller, and the exception's namespace must also be listed in `--exceptionNamespace`.
*   **C)** `PolicyException` only works for `mutate` rules, never `validate` rules.
*   **D)** The object was applied to the wrong CRD version; `PolicyException` does not exist in Kyverno.

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: B**

*   **Why B is correct:** `PolicyException` evaluation is off by default. Two admission-controller flags gate it: `--enablePolicyException=true` turns the feature on at all, and `--exceptionNamespace=<ns>` restricts which namespace(s) are trusted to author an exception Kyverno will actually honor. An exception outside that allow-list is as inert as if the feature were off.
*   **Why others are incorrect:**
    *   *Option A* invents a propagation delay that does not exist — admission-time evaluation is synchronous.
    *   *Option C* is wrong — `PolicyException` can exempt any rule action type, not just `mutate`.
    *   *Option D* is wrong — `PolicyException` is a real, current Kyverno CRD (`policies.kyverno.io/v1`).
</details>

---

### Question 2
Which two admission-controller flags together enable and scope `PolicyException` evaluation?
*   **A)** `--exceptions=true` and `--exceptionScope=<ns>`
*   **B)** `--enablePolicyException=true` and `--exceptionNamespace=<ns>`
*   **C)** `--policyExceptionEnabled=true` and `--trustedNamespace=<ns>`
*   **D)** A single flag, `--policyExceptions=<ns>`, that both enables and scopes it.

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: B**

*   **Why B is correct:** These are the two documented flag names — `--enablePolicyException=true` turns evaluation on, and `--exceptionNamespace=<ns>` names the namespace(s) trusted to author one that will actually be honored.
*   **Why others are incorrect:** *Options A, C, and D* invent flag names that do not exist in Kyverno.
</details>

---

### Question 3
What is the practical difference between `PolicyReport`/`ClusterPolicyReport` and `AdmissionReport`/`BackgroundScanReport`?
*   **A)** There is no difference; they are aliases for the same underlying objects.
*   **B)** `PolicyReport`/`ClusterPolicyReport` are the stable, end-user-facing aggregated results; `AdmissionReport`/`BackgroundScanReport` are internal, ephemeral intermediaries the reports-controller merges upward and are not meant for direct consumption.
*   **C)** `AdmissionReport`/`BackgroundScanReport` are the only ones that persist; `PolicyReport`/`ClusterPolicyReport` are deleted after five minutes.
*   **D)** `PolicyReport` covers `validate` rules only; `AdmissionReport` covers `mutate` and `generate` rules.

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: B**

*   **Why B is correct:** `AdmissionReport`/`ClusterAdmissionReport` and `BackgroundScanReport`/`ClusterBackgroundScanReport` (`kyverno.io/v1alpha2`) are per-request or per-scan intermediary objects, high-churn and internal. The reports-controller merges them into the stable `PolicyReport`/`ClusterPolicyReport` (`wgpolicyk8s.io/v1alpha2`) objects, which are the durable, intended read surface.
*   **Why others are incorrect:** *Options A, C, and D* misstate the actual relationship and lifecycle between the two families.
</details>

---

### Question 4
A `ClusterCleanupPolicy` needs to delete every Deployment labeled `canremove: "true"` whose `spec.replicas` has dropped below `2`, checked every five minutes. Which three spec fields does it combine to express this?
*   **A)** `webhook`, `timeoutSeconds`, `failurePolicy`
*   **B)** `match` (select by label), `conditions` (the replicas check), and `schedule` (the cron expression)
*   **C)** `rules`, `validate`, `generate`
*   **D)** `selector`, `retentionPolicy`, `interval`

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: B**

*   **Why B is correct:** `match`/`exclude` select candidate resources exactly like a `ClusterPolicy`; an optional `conditions` block (the same condition-operator vocabulary as `deny.conditions`) narrows further on live field values; `schedule` is a standard cron expression the cleanup-controller evaluates on that cadence.
*   **Why others are incorrect:** *Options A, C, and D* invent or misapply fields that belong to other Kyverno concepts (webhook configuration, validate/generate rules, and non-existent field names respectively).
</details>

---

### Question 5
As of which Kyverno version is `CleanupPolicy`/`ClusterCleanupPolicy` deprecated, and in favor of what replacement?
*   **A)** Deprecated as of v1.10, replaced by `mutate.targets`.
*   **B)** Deprecated as of v1.19, replaced by `DeletingPolicy`, with removal planned for v1.20.
*   **C)** It is not deprecated; it is Kyverno's current, recommended cleanup mechanism with no planned replacement.
*   **D)** Deprecated as of v1.19, replaced by `GlobalContextEntry`.

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: B**

*   **Why B is correct:** `CleanupPolicy`/`ClusterCleanupPolicy` is deprecated as of Kyverno v1.19 in favor of a new `DeletingPolicy` CRD, scheduled for removal in v1.20 — it remains exam-relevant for current material and widely deployed clusters in the meantime.
*   **Why others are incorrect:** *Option A* invents an unrelated version and replacement. *Option C* is factually wrong about deprecation status. *Option D* names the wrong replacement — `GlobalContextEntry` solves a completely different problem (caching external data).
</details>

---

### Question 6
What does a `GlobalContextEntry` do?
*   **A)** It globally disables all policies matching a given resource kind.
*   **B)** It caches the result of an `apiCall` or a watched Kubernetes resource list, on a refresh interval, so multiple policies can reuse the same fetched data instead of each issuing a redundant call.
*   **C)** It defines a cluster-wide default `match`/`exclude` block inherited by every `ClusterPolicy`.
*   **D)** It stores a global audit log of every admission decision Kyverno has ever made.

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: B**

*   **Why B is correct:** `GlobalContextEntry` (`kyverno.io/v2alpha1`, cluster-scoped) is a caching mechanism — it fetches an `apiCall` result or watches a Kubernetes resource list, refreshing on an interval, so any rule referencing the cached entry avoids performing its own independent lookup on every admission request.
*   **Why others are incorrect:** *Options A, C, and D* invent capabilities `GlobalContextEntry` does not have; none of Kyverno's CRDs provide a global policy kill-switch, an inherited default match block, or a built-in audit log.
</details>

---

### Question 7
You want the single fastest way to confirm the complete set of API resources — kind, short name, API version, and namespaced/cluster scope — that Kyverno contributes to a specific cluster, without cross-referencing documentation for that exact installed version. What command do you run?
*   **A)** `kubectl get events -n kyverno`
*   **B)** `kubectl api-resources | grep -i kyverno`
*   **C)** `helm show values kyverno/kyverno`
*   **D)** `kubectl get pods -n kyverno -o wide`

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: B**

*   **Why B is correct:** `kubectl api-resources` lists every API resource type the API server currently serves, including `SHORTNAMES`, `APIVERSION`, and the `NAMESPACED` column — filtering it for `kyverno` gives you the live, version-accurate CRD surface directly from the cluster itself, no docs cross-reference needed.
*   **Why others are incorrect:**
    *   *Option A* shows cluster events, unrelated to enumerating API resource types.
    *   *Option C* shows Helm chart default *values*, not the resulting live API surface.
    *   *Option D* lists running Pods, not registered API resource kinds.
</details>
