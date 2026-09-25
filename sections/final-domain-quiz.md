# KCA Installation, Configuration, and Upgrades Certification Quiz

Welcome to the Final Domain Certification Quiz for the **ATS008: Installation, Configuration, and Upgrades** curriculum. This comprehensive test contains **12 high-signal, scenario-based questions** covering all 6 modules across the 6 sections.

To simulate exam-style pressure:
*   Answer all 12 questions without consulting external documentation or the Kyverno/Helm CLI.
*   Allow yourself a maximum of **20 minutes** to complete the entire test.
*   Once finished, scroll to the very bottom to check the **Audit and Review Key** to trace any incorrect answers back to their exact section and module chapters.

---

## The Exam Simulator

### Question 1
You are about to install Kyverno for the first time on a new cluster. A teammate suggests installing it into the `default` namespace since "it's just one more app." What is the correct guidance, and why?
*   **A)** That's fine — Kyverno has no special namespace requirements.
*   **B)** Kyverno must be installed into its own dedicated namespace, never co-located with other applications, because of the blast radius of its cluster-wide webhooks and RBAC, and to keep upgrade/rollback isolated from unrelated workloads.
*   **C)** Kyverno must be installed into `kube-system` specifically, since it is a cluster-critical component.
*   **D)** The namespace only matters for the CRDs; the controllers themselves can run anywhere.

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: B**

*   **Why B is correct:** Kyverno documentation is explicit that it must run in a dedicated namespace (conventionally `kyverno`), never co-located with other applications. This isolates its cluster-wide admission webhooks and its aggregated RBAC from unrelated workloads, and keeps a Helm upgrade or rollback of Kyverno from having any chance of touching something else in a shared namespace.
*   **Why others are incorrect:**
    *   *Option A* ignores a documented, load-bearing requirement.
    *   *Option C* is wrong — `kube-system` is not the documented target; the standard convention is a dedicated `kyverno` namespace, not the cluster's own system namespace.
    *   *Option D* is wrong — the dedicated-namespace requirement applies to the whole install (CRDs are cluster-scoped anyway and unaffected by namespace, but the controllers, webhooks, and RBAC all benefit from the isolation).
</details>

---

### Question 2
You run `helm upgrade --install kyverno kyverno/kyverno -n kyverno -f values.yaml` to apply a values file with `admissionController.replicas: 2` set, on a cluster where Kyverno is not yet installed at all. What happens?
*   **A)** The command fails, because `helm upgrade` requires an existing release.
*   **B)** The command installs Kyverno fresh with the given values, because `--install` makes `helm upgrade` idempotent — it upgrades if the release exists, or installs it if it doesn't.
*   **C)** The command silently does nothing, since there is nothing to upgrade.
*   **D)** The command installs Kyverno but ignores `values.yaml`, since `-f` only applies during a true upgrade.

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: B**

*   **Why B is correct:** The `--install` flag is exactly what makes `helm upgrade --install` the standard idempotent pattern: the same command works whether this is the very first install or a later configuration change, and `-f values.yaml` applies in both cases.
*   **Why others are incorrect:**
    *   *Option A* describes plain `helm upgrade` without `--install`, not what was run here.
    *   *Option C* is wrong — the command performs a real install.
    *   *Option D* is wrong — values files apply identically whether Helm is performing a first install or a subsequent upgrade under `--install`.
</details>

---

### Question 3
Your cluster runs a `ClusterPolicy` named `require-owner-label` that blocks any Deployment missing an `owner` label. You need to admit exactly one specific, already-approved Deployment named `legacy-app` without loosening the policy for anyone else, and without touching the policy itself. Which Kyverno CRD is designed for this?
*   **A)** A second `ClusterPolicy` with `validationFailureAction: Audit` that overrides the first.
*   **B)** `PolicyException` (`kyverno.io/v2`) — a namespaced resource that exempts a specific match from a named policy's named rule(s), and which must be explicitly enabled on the admission controller before it has any effect.
*   **C)** `CleanupPolicy`, since it can exclude resources from other policies.
*   **D)** `GlobalContextEntry`, since it can override policy evaluation results.

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: B**

*   **Why B is correct:** `PolicyException` is purpose-built for exactly this — a narrow, auditable carve-out for a specific resource from a specific policy's specific rule(s), leaving the policy itself, and its effect on everything else, untouched. It is disabled by default and only takes effect once the admission controller is started with `--enablePolicyException=true` and an `--exceptionNamespace` covering where the exception lives.
*   **Why others are incorrect:**
    *   *Option A* would weaken enforcement for every resource the second policy's rule matches, not just `legacy-app` — the opposite of a narrow carve-out.
    *   *Option C* is wrong — `CleanupPolicy` schedules deletion of resources on a schedule; it has nothing to do with exempting a resource from another policy.
    *   *Option D* is wrong — `GlobalContextEntry` caches external/cluster data for policies to read as a variable; it does not override or exempt evaluation results.
</details>

---

### Question 4
You run `kubectl get admissionreport -A` and see several entries reflecting recent Pod admissions. A teammate asks if this is the right place to check a Pod's overall policy compliance history. What should you tell them?
*   **A)** Yes — `AdmissionReport` is the canonical, user-facing compliance record.
*   **B)** No — `AdmissionReport`/`ClusterAdmissionReport` (and their background-scan counterparts) are internal, ephemeral intermediary objects the reports controller uses to build the real user-facing record, `PolicyReport`/`ClusterPolicyReport` (`wgpolicyk8s.io/v1alpha2`) — that's what should be read directly.
*   **C)** No — compliance history isn't tracked anywhere in Kyverno; only live admission decisions are.
*   **D)** Yes, but only for cluster-scoped resources; namespaced resources use a different, undocumented mechanism.

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: B**

*   **Why B is correct:** `AdmissionReport`/`ClusterAdmissionReport` and `BackgroundScanReport`/`ClusterBackgroundScanReport` (all `kyverno.io/v1alpha2`) are internal building blocks the reports controller merges together; the aggregated, human-readable result users should actually read is `PolicyReport`/`ClusterPolicyReport` under the `wgpolicyk8s.io/v1alpha2` API group, visible with `kubectl get policyreport -A`.
*   **Why others are incorrect:**
    *   *Option A* elevates an internal implementation detail to something it was never meant to be read as directly.
    *   *Option C* is factually wrong — compliance history is tracked, just via the aggregated report CRDs, not by claiming it doesn't exist.
    *   *Option D* invents a namespaced/cluster-scoped split that isn't the actual distinction (the actual distinction is internal-intermediary vs. user-facing-aggregate, and both have namespaced and cluster-scoped variants).
</details>

---

### Question 5
You need to reduce concurrency on `generate` rule processing because it's putting unwanted load on the API server during a migration. Which controller and which flag do you change?
*   **A)** The admission controller's `--maxAuditWorkers`.
*   **B)** The background controller's `--genWorkers`.
*   **C)** The reports controller's `--backgroundScanWorkers`.
*   **D)** The cleanup controller's `--ttlReconciliationInterval`.

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: B**

*   **Why B is correct:** `generate` rule processing is handled by the background controller, and `--genWorkers` (default 10) is the flag that controls its concurrency — lowering it directly reduces how many generate operations run in parallel.
*   **Why others are incorrect:**
    *   *Option A* controls the admission controller's async **audit-mode validate** concurrency, unrelated to `generate` rules.
    *   *Option C* controls how many workers the reports controller uses for periodic **background scanning** of existing resources against policies, not `generate` processing.
    *   *Option D* controls how often the cleanup controller reconciles TTL-based deletions, unrelated to `generate` rules entirely.
</details>

---

### Question 6
You use `kubectl patch deployment kyverno-admission-controller -n kyverno --type=json` to add `--enablePolicyException=true` as an emergency fix, confirm it works, and move on. Three weeks later a teammate runs `helm upgrade kyverno kyverno/kyverno -n kyverno` for an unrelated reason, and PolicyException support stops working. What happened, and what should have been done instead?
*   **A)** Nothing should have been different — this is a Kyverno bug.
*   **B)** The live `kubectl patch` was never reflected in the Helm release's values, so the next `helm upgrade` re-rendered the Deployment from the chart defaults and silently reverted it; the durable fix is the chart's `admissionController.container.extraArgs` value, applied via `-f values.yaml` (or `--set`) so it survives every future upgrade.
*   **C)** `kubectl patch` changes are permanent and this must be an unrelated regression.
*   **D)** The fix should have used `kubectl edit` instead of `kubectl patch`, since only `patch` changes are reverted by Helm.

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: B**

*   **Why B is correct:** A live `kubectl edit`/`kubectl patch` on a Helm-managed Deployment only changes the live object — it does not change the Helm release's recorded values. The next `helm upgrade` re-renders the Deployment from the chart template plus the release's actual values, which never included the live patch, so it's overwritten. The durable equivalent is the chart's `extraArgs` value (`admissionController.container.extraArgs` for the admission controller), committed to the values file that's actually used for upgrades.
*   **Why others are incorrect:**
    *   *Option A* mislabels expected, documented Helm reconciliation behavior as a bug.
    *   *Option C* is factually wrong — a live patch on a Helm-managed resource is exactly this fragile.
    *   *Option D* is wrong — both `kubectl edit` and `kubectl patch` change only the live object; neither is reflected in the Helm release's stored values, so both are equally reverted by the next `helm upgrade`.
</details>

---

### Question 7
You want to grant the Kyverno **background controller** permission to read a custom CRD it doesn't have by default, so a `generate` rule can reference it. What is the documented best practice?
*   **A)** Edit Kyverno's shipped `kyverno:background-controller:core` ClusterRole directly to add the new rule.
*   **B)** Create a brand-new ClusterRole with the needed rule, carrying the label `rbac.kyverno.io/aggregate-to-background-controller: "true"`, so Kubernetes' own ClusterRole aggregation mechanism unions it into the background controller's permission set automatically.
*   **C)** Grant `cluster-admin` to the `kyverno-background-controller` ServiceAccount to avoid permission issues entirely.
*   **D)** Restart the background controller Pod — Kyverno automatically re-discovers and grants any permissions its currently-loaded policies need.

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: B**

*   **Why B is correct:** Kyverno's per-controller ClusterRoles are themselves aggregate ClusterRoles with no rules of their own — they use `aggregationRule.clusterRoleSelectors` to pull in rules from any ClusterRole carrying the matching `rbac.kyverno.io/aggregate-to-<controller>-controller` label. Extending permissions the supported way means adding a new labeled ClusterRole, which Kubernetes automatically unions in — no edit to Kyverno's own shipped roles required.
*   **Why others are incorrect:**
    *   *Option A* is explicitly the anti-pattern: editing a shipped default ClusterRole gets silently reset on the next Helm upgrade or manifest re-apply.
    *   *Option C* massively over-grants a controller identity, defeating the entire point of Kyverno's least-privilege, per-controller RBAC design.
    *   *Option D* invents automatic permission discovery that Kyverno does not perform — RBAC is never inferred from policy content.
</details>

---

### Question 8
You run `kubectl auth can-i list secrets --as=kyverno-background-controller -A` and it returns `yes`, which surprises you since you never explicitly granted that. What is the most likely explanation?
*   **A)** The command is checking as the intended ServiceAccount identity, and Kyverno secretly grants secrets access to all controllers by default.
*   **B)** The command's `--as=kyverno-background-controller` is missing the full `system:serviceaccount:<namespace>:<name>` form, so it was actually evaluated as the caller's own (likely highly privileged) identity, not the ServiceAccount at all — the result doesn't reflect the controller's real permissions.
*   **C)** `kubectl auth can-i` always returns `yes` for `list` verbs regardless of actual RBAC.
*   **D)** This proves the background controller has a bug granting it excessive default permissions.

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: B**

*   **Why B is correct:** `--as` for a ServiceAccount identity requires the full form `system:serviceaccount:<namespace>:<name>` (e.g. `system:serviceaccount:kyverno:kyverno-background-controller`). A bare name like `kyverno-background-controller` is not a valid ServiceAccount identity string, so Kubernetes doesn't impersonate it as expected — commonly falling back to evaluating as the actual caller's own identity, which is frequently over-privileged (e.g. a cluster-admin kubeconfig), producing a misleading `yes`.
*   **Why others are incorrect:**
    *   *Option A* invents a default grant that doesn't exist and misreads what actually happened with the malformed `--as` value.
    *   *Option C* is not how `kubectl auth can-i` works — it performs a real RBAC evaluation.
    *   *Option D* jumps to "Kyverno bug" without first ruling out the actual, far more common cause: a malformed `--as` identity string.
</details>

---

### Question 9
You scale `backgroundController.replicas` from 1 to 4, expecting `generate` rule throughput to roughly quadruple under load. What actually happens?
*   **A)** Throughput does quadruple, since all four replicas process work in parallel.
*   **B)** Throughput is essentially unchanged — the background controller uses leader election, so only one of the four replicas is ever doing the actual processing at a time; the other three exist purely as standby failover if the leader pod is lost.
*   **C)** Throughput actually decreases, since replicas now compete for the same lease.
*   **D)** The background controller ignores `replicas` entirely; it always runs exactly one Pod regardless of the value.

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: B**

*   **Why B is correct:** Unlike the admission controller, the background controller uses leader election for its actual processing work — regardless of replica count, only the currently-elected leader does the real generate/mutate-existing work. Extra replicas provide availability (fast failover if the leader Pod dies), not additional throughput.
*   **Why others are incorrect:**
    *   *Option A* describes the admission controller's model (no leader election, every replica active), not the background controller's.
    *   *Option C* invents a made-up contention penalty; non-leader replicas sit idle/standby, they don't compete for or slow down the leader.
    *   *Option D* is wrong — the Deployment genuinely runs 4 Pods; only the *processing* work is singleton, not the replica count itself.
</details>

---

### Question 10
Kyverno's documentation recommends a minimum of 3 replicas for the admission controller in production. What is the primary technical reason this number applies specifically to the admission controller and not, say, the reports controller?
*   **A)** 3 is an arbitrary round number applied uniformly to every Kyverno component.
*   **B)** The admission controller serves live `AdmissionReview` webhook traffic with no leader election — every replica is simultaneously active and load-balanced by the Service, so replica count directly buys both real request-handling throughput and availability; documented load testing showed 3 replicas keeping p99 latency well under 1 second under heavy concurrent load where 1 replica did not.
*   **C)** The reports controller cannot run more than 1 replica at all, so the comparison is meaningless.
*   **D)** 3 replicas are required so the admission controller can run its own internal 3-node leader-election quorum.

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: B**

*   **Why B is correct:** Because the admission controller has no leader election for webhook serving, every replica actively handles real traffic, so replica count is a direct throughput and latency lever — which is exactly what Kyverno's own load-test data (3 replicas keeping p99 under ~650ms at 500 concurrent users, versus over 1s at 1 replica) demonstrates and justifies. That reasoning simply doesn't transfer to a leader-elected controller where only one replica ever does the real work.
*   **Why others are incorrect:**
    *   *Option A* denies that this is a data-driven recommendation specific to the admission controller's architecture.
    *   *Option C* is wrong — the reports controller can absolutely run multiple replicas (2 is a common HA setting); it just doesn't gain processing throughput from them.
    *   *Option D* invents a leader-election quorum concept Kyverno's admission controller doesn't use for webhook serving.
</details>

---

### Question 11
You are upgrading Kyverno from an older to a newer chart version via `helm upgrade --install kyverno kyverno/kyverno -n kyverno -f values.yaml`. A colleague warns "Helm never upgrades CRDs, so you'll need to manually apply the new CRDs first." Is this accurate for Kyverno specifically?
*   **A)** Yes — this is universally true for every Helm chart including Kyverno's, with no exceptions.
*   **B)** No — that folklore is about Helm's special `crds/` directory convention specifically, which is install-only by design; Kyverno deliberately ships its CRDs as regular templated resources in a chart dependency gated by `crds.install`, so a normal `helm upgrade` does update them.
*   **C)** No, because Kyverno has no CRDs at all as of recent versions.
*   **D)** Yes, but only when upgrading across a major version boundary; minor-version upgrades are exempt.

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: B**

*   **Why B is correct:** The "Helm never upgrades CRDs" rule of thumb refers specifically to Helm's dedicated `crds/` directory feature, which by design is applied only on install, never on upgrade. Kyverno sidesteps this entirely by shipping its CRDs as ordinary templated Kubernetes manifests inside a chart dependency (controlled by `crds.install`), which Helm treats like any other template — rendered and applied on every `helm upgrade`, same as a Deployment or ConfigMap.
*   **Why others are incorrect:**
    *   *Option A* states the common folklore as if it had no exceptions, which is exactly the misconception this module corrects.
    *   *Option C* is factually wrong — Kyverno ships many CRDs; the question is about how they're upgraded, not whether they exist.
    *   *Option D* invents a major/minor distinction that isn't how Helm's `crds/`-directory limitation actually works — it applies (or in Kyverno's case, doesn't apply) uniformly regardless of version delta.
</details>

---

### Question 12
Your cluster's Kyverno was installed two years ago via `kubectl create -f install.yaml` (raw manifest), never Helm. You need to upgrade it to the current version. What is the documented upgrade procedure?
*   **A)** `kubectl apply -f` the new version's manifest directly over the old one — this cleanly reconciles the difference the same way `helm upgrade` would.
*   **B)** There is no supported in-place upgrade path for a raw-manifest install; the documented procedure is to uninstall using the *original* release's manifest first, then install the new version's manifest fresh.
*   **C)** Raw-manifest installs cannot be upgraded under any circumstances and the cluster must be rebuilt.
*   **D)** Run `helm upgrade` anyway — Helm can adopt and upgrade a release it didn't originally install.

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: B**

*   **Why B is correct:** Kyverno's documentation is explicit that raw-manifest installs have no supported in-place upgrade path the way a Helm release does — the documented procedure is to uninstall with the original manifest, then install fresh with the new one. This asymmetry (versus Helm's smooth `helm upgrade --install`) is a concrete, practical reason to prefer Helm for any Kyverno install from day one.
*   **Why others are incorrect:**
    *   *Option A* overstates what `kubectl apply -f` reconciliation guarantees across arbitrary version deltas for a complex multi-resource install — it is not the documented, supported path for a Kyverno upgrade.
    *   *Option C* overstates the limitation — an upgrade path exists (uninstall-then-reinstall), it's just not in-place.
    *   *Option D* is wrong — Helm has no release record for something it never installed; there's nothing for `helm upgrade` to reconcile against.
</details>

---

## Audit and Review Key

Check your score and use this review matrix to trace any incorrect answers back to their exact section and module chapters:

| Question | Targeted Kyverno Competency | Review Chapter |
| :--- | :--- | :--- |
| **Q1** | Dedicated-namespace requirement for a Helm install | **[Section 010, Module 01](./section-010/module-01/course.md)** |
| **Q2** | `helm upgrade --install` idempotent pattern | **[Section 010, Module 01](./section-010/module-01/course.md)** |
| **Q3** | PolicyException CRD, scope, and default-disabled state | **[Section 020, Module 01](./section-020/module-01/course.md)** |
| **Q4** | Internal AdmissionReport vs. user-facing PolicyReport | **[Section 020, Module 01](./section-020/module-01/course.md)** |
| **Q5** | Per-controller flag ownership (`--genWorkers` etc.) | **[Section 030, Module 01](./section-030/module-01/course.md)** |
| **Q6** | Live patch vs. durable `extraArgs` on Helm-managed Deployments | **[Section 030, Module 01](./section-030/module-01/course.md)** |
| **Q7** | Aggregated ClusterRole extension pattern | **[Section 040, Module 01](./section-040/module-01/course.md)** |
| **Q8** | `kubectl auth can-i --as=system:serviceaccount:<ns>:<name>` syntax | **[Section 040, Module 01](./section-040/module-01/course.md)** |
| **Q9** | Background controller leader-election, availability-only replicas | **[Section 050, Module 01](./section-050/module-01/course.md)** |
| **Q10** | Admission controller horizontal scale & the documented 3-replica floor | **[Section 050, Module 01](./section-050/module-01/course.md)** |
| **Q11** | Kyverno's CRD-upgrade exception to Helm's `crds/`-folder folklore | **[Section 060, Module 01](./section-060/module-01/course.md)** |
| **Q12** | Raw-manifest uninstall-then-reinstall upgrade limitation | **[Section 060, Module 01](./section-060/module-01/course.md)** |
