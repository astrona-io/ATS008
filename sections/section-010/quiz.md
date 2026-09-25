# Section 010 Knowledge Check: Helm-based Installation and Configuration

Test your understanding of the Helm repo/install flow, the dedicated-namespace rule, CRD auto-management, values customization, and auditing an installed release.

---

## Scenario-Based Questions

### Question 1
A teammate proposes installing Kyverno into the existing `platform-tools` namespace, alongside an internal dashboard and a metrics exporter, to "keep things consolidated." What should you tell them?
*   **A)** This is fine — Kyverno has no namespace requirements beyond being a valid Kubernetes namespace.
*   **B)** Kyverno's own documentation requires it to be installed in a dedicated namespace and never co-located with other applications, so it should get its own namespace (conventionally `kyverno`).
*   **C)** It's only a problem if the other applications also use Helm.
*   **D)** It's fine as long as `crds.install` is set to `false`.

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: B**

*   **Why B is correct:** Kyverno's documentation is explicit: it must always live in a dedicated namespace, never co-located with other applications. This isolates its RBAC, webhook TLS secrets, and controller identity from unrelated workloads.
*   **Why others are incorrect:**
    *   *Option A* ignores Kyverno's own documented requirement.
    *   *Option C* invents a Helm-specific exception that does not exist — the rule is about namespace co-location, not the install tool.
    *   *Option D* confuses CRD management with namespace isolation; `crds.install` has nothing to do with where Kyverno's controllers live.
</details>

---

### Question 2
After `helm install kyverno kyverno/kyverno -n kyverno --create-namespace` with default values, you run `kubectl get crd | grep kyverno.io` and see `clusterpolicies.kyverno.io` and friends already present. What Helm value made that happen?
*   **A)** `admissionController.installCRDs: true`
*   **B)** `crds.install: true` (the default), which installs Kyverno's CRDs via a dedicated chart dependency.
*   **C)** Nothing — Helm always installs every CRD referenced anywhere in a chart automatically, with no toggle.
*   **D)** `backgroundController.enabled: true`, which happens to also install CRDs as a side effect.

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: B**

*   **Why B is correct:** `crds.install` (default `true`) is the specific toggle controlling whether Helm installs Kyverno's CRDs, via a dedicated CRDs chart dependency.
*   **Why others are incorrect:**
    *   *Option A* invents a field that doesn't exist.
    *   *Option C* is wrong in general — Helm's handling of CRDs varies by chart design, which is exactly why Kyverno needs its own explicit toggle.
    *   *Option D* confuses an unrelated controller toggle with CRD installation.
</details>

---

### Question 3
You need the admission controller to run 2 replicas instead of the default. Which values.yaml path is correct?
*   **A)** `admissionController.container.replicas: 2`
*   **B)** `admissionController.replicas: 2`
*   **C)** `admissionController.replicaCount: 2`
*   **D)** `controllers.admission.replicas: 2`

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: B**

*   **Why B is correct:** `admissionController.replicas` is the exact key path in Kyverno's chart `values.yaml` for the admission controller's desired pod count.
*   **Why others are incorrect:**
    *   *Option A* wrongly nests `replicas` under `.container.`, which is where `resources` lives, not `replicas`.
    *   *Option C* invents a `replicaCount` field name from a different Helm chart convention that this chart does not use.
    *   *Option D* invents a `controllers.admission.*` namespace that doesn't exist in this chart.
</details>

---

### Question 4
Where do you set the admission controller container's CPU/memory resource requests?
*   **A)** `admissionController.resources.requests`
*   **B)** `admissionController.container.resources.requests`
*   **C)** `resources.admissionController.requests`
*   **D)** `admissionController.container.requests`

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: B**

*   **Why B is correct:** Unlike `replicas`, `resources` nests one level deeper, under `admissionController.container.resources`, with the usual Kubernetes `requests`/`limits` sub-keys.
*   **Why others are incorrect:**
    *   *Option A* omits the required `.container.` nesting level.
    *   *Option C* inverts the nesting order the chart actually uses.
    *   *Option D* drops the intermediate `resources` key.
</details>

---

### Question 5
You want one command that installs Kyverno if the release doesn't exist yet, or upgrades it in place if it does — safe to re-run identically from a CI pipeline. What should that command use?
*   **A)** `helm install kyverno kyverno/kyverno -n kyverno --create-namespace`, re-run every time.
*   **B)** `helm upgrade --install kyverno kyverno/kyverno -n kyverno --create-namespace -f values.yaml`
*   **C)** `helm template kyverno/kyverno | kubectl apply -f -`
*   **D)** `helm uninstall kyverno -n kyverno && helm install kyverno kyverno/kyverno -n kyverno`

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: B**

*   **Why B is correct:** `helm upgrade --install` is Helm's own idempotent pattern: install if missing, upgrade if present — exactly the "safe to re-run" behavior a CI pipeline needs.
*   **Why others are incorrect:**
    *   *Option A* fails on the second run with an "already exists" error.
    *   *Option C* bypasses Helm's release tracking entirely (no `helm list`/`helm history` visibility).
    *   *Option D* works but needlessly destroys and recreates the release every time, causing avoidable downtime.
</details>

---

### Question 6
You ran `helm install` with two `--set` overrides. You now want to see the complete effective configuration — your overrides plus every value still at its chart default — for the running release. What command shows that?
*   **A)** `helm get values kyverno -n kyverno` (no flags)
*   **B)** `helm get values kyverno -n kyverno -a`
*   **C)** `helm show values kyverno/kyverno`
*   **D)** `kubectl get deploy -n kyverno -o yaml`

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: B**

*   **Why B is correct:** `helm get values <release> -a` (`--all`) shows the fully merged effective values — your overrides layered on the chart's defaults — for the installed release.
*   **Why others are incorrect:**
    *   *Option A* without `-a` only shows the values *you* explicitly set, hiding everything still at its default, which is not the "complete" picture asked for.
    *   *Option C* shows the chart's defaults before any install, not what a specific running release actually has.
    *   *Option D* shows the resulting Kubernetes objects, not the Helm values that produced them — much harder to audit directly.
</details>

---

### Question 7
Kyverno's default `config.excludeGroups` is `["system:serviceaccounts:kube-system", "system:nodes"]`. You run `helm upgrade --reuse-values -n kyverno kyverno kyverno/kyverno --set config.excludeGroups[0]=system:serviceaccounts:ci`. What is the resulting effective value of `config.excludeGroups`?
*   **A)** `["system:serviceaccounts:kube-system", "system:nodes", "system:serviceaccounts:ci"]` — Helm appends new list entries.
*   **B)** `["system:serviceaccounts:ci"]` — the whole list was replaced with just the new single entry, silently dropping both defaults.
*   **C)** The command fails outright, since Kyverno protects its default exclude groups from being overridden.
*   **D)** `["system:serviceaccounts:ci", "system:nodes"]` — only index `0` is replaced, the rest of the list is preserved.

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: B**

*   **Why B is correct:** Helm treats a list-valued override as a full replacement of that list, not a merge or a per-index patch. Setting `excludeGroups[0]` to a single new value replaces the entire `excludeGroups` array with `["system:serviceaccounts:ci"]`, silently dropping the built-in defaults.
*   **Why others are incorrect:**
    *   *Option A* describes append/merge behavior Helm does not perform for list overrides.
    *   *Option C* invents a protection mechanism that does not exist.
    *   *Option D* misunderstands `--set` array-index syntax — it does not preserve unrelated array length/defaults from the chart; the final effective list only contains what was explicitly set.
</details>
