# Section 040 Knowledge Check: Configuring Kyverno RBAC, Roles, and Permissions

Test your understanding of Kyverno's per-controller ServiceAccounts, aggregated ClusterRoles, the built-in `view` binding, and how to safely extend permissions.

---

## Scenario-Based Questions

### Question 1
Which ServiceAccount does Kyverno's background controller run under, and in which namespace?
*   **A)** `kyverno-controller`, in `kube-system`.
*   **B)** `kyverno-background-controller`, in `kyverno`.
*   **C)** `kyverno`, in `kyverno-system`.
*   **D)** A shared `kyverno-sa` used by all four controllers, in `kyverno`.

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: B**

*   **Why B is correct:** Kyverno runs four independent controllers, each under its own ServiceAccount in the `kyverno` namespace: `kyverno-admission-controller`, `kyverno-background-controller`, `kyverno-reports-controller`, and `kyverno-cleanup-controller`.
*   **Why others are incorrect:**
    *   *Option A* invents a name and namespace that don't match Kyverno's actual layout.
    *   *Option C* swaps the namespace/name convention.
    *   *Option D* is wrong — a shared ServiceAccount would defeat the purpose of scoping each controller's permissions independently.
</details>

---

### Question 2
You need to extend the permissions of Kyverno's reports controller specifically. Which label should your new `ClusterRole` carry?
*   **A)** `rbac.kyverno.io/aggregate-to-reports-controller: "true"`
*   **B)** `kyverno.io/controller: reports`
*   **C)** `rbac.kyverno.io/extend: reports-controller`
*   **D)** `app.kubernetes.io/component: reports-controller`

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: A**

*   **Why A is correct:** Kyverno's aggregation labels follow the pattern `rbac.kyverno.io/aggregate-to-<controller>-controller: "true"` — one distinct label per controller. Any ClusterRole carrying the matching label is automatically folded into that controller's effective permissions via Kubernetes ClusterRole aggregation.
*   **Why others are incorrect:**
    *   *Options B, C, and D* invent label keys/values that do not match Kyverno's actual aggregation convention.
</details>

---

### Question 3
A `generate` rule that creates `ConfigMap` resources works fine, but a new `generate` rule targeting a custom CRD fails silently. The policy YAML is valid and applies without error. What is the most likely cause?
*   **A)** Kyverno only supports `generate` rules for core Kubernetes resource kinds.
*   **B)** The background controller's ServiceAccount lacks `create`/`update` permission on that CRD, and needs a new aggregated ClusterRole.
*   **C)** The rule needs `background: false` to target custom resources.
*   **D)** Custom resources must be explicitly whitelisted in the ConfigMap named `kyverno`.

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: B**

*   **Why B is correct:** A valid `generate` rule can still fail to actually create its target resource if the background controller's ServiceAccount doesn't have the RBAC to do so. The fix is a new ClusterRole carrying `rbac.kyverno.io/aggregate-to-background-controller: "true"` and granting the needed verbs on that resource kind — not a policy change.
*   **Why others are incorrect:**
    *   *Option A* is false — `generate` works against any resource kind Kyverno has RBAC for, core or custom.
    *   *Option C* is unrelated — `background` controls periodic re-scanning of existing resources, not generate-target RBAC.
    *   *Option D* invents a whitelist mechanism that doesn't exist for this purpose.
</details>

---

### Question 4
What does the built-in `view` ClusterRole binding give Kyverno's admission, background, and reports controllers?
*   **A)** Full CRUD access to every namespaced resource, so any rule action works out of the box.
*   **B)** Broad read-only (`get`/`list`/`watch`) access to most namespaced resources, supporting `match`/`context` lookups and background scans.
*   **C)** Read access limited strictly to `ClusterPolicy` and `Policy` objects.
*   **D)** Write access to ConfigMaps only, for storing scan results.

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: B**

*   **Why B is correct:** The `view` binding is Kubernetes' standard broad read-only ClusterRole. Binding it to Kyverno's controllers lets `match`/`context` evaluation and background scanning inspect namespaced resources without a bespoke read-permission entry for every single kind — but it grants no write access.
*   **Why others are incorrect:**
    *   *Option A* overstates it — `view` is read-only; write access (for `mutate`/`generate`) comes from separate, narrower aggregated rules.
    *   *Option C* undersells the built-in `view` role's actual scope, which covers most namespaced resource kinds, not just Kyverno's own CRDs.
    *   *Option D* invents a write capability `view` does not grant.
</details>

---

### Question 5
You need to grant Kyverno's background controller permission to `create` a resource kind it currently can't. What should you do?
*   **A)** Run `kubectl edit clusterrole kyverno:background-controller:core` and add the rule directly.
*   **B)** Create a new, separately-named ClusterRole carrying the correct aggregation label, granting only the needed rule.
*   **C)** Bind the background controller's ServiceAccount to `cluster-admin` temporarily.
*   **D)** Edit the Kyverno Helm chart's templates locally and re-install.

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: B**

*   **Why B is correct:** Kyverno's own guidance is explicit that default roles should not be modified — new roles should be used to extend them. A new ClusterRole with the right aggregation label is folded in automatically and survives future upgrades untouched.
*   **Why others are incorrect:**
    *   *Option A* directly edits a shipped role, which gets silently reverted on the next `helm upgrade`.
    *   *Option C* massively over-grants permissions, defeating the purpose of Kyverno's narrowly-scoped RBAC design.
    *   *Option D* is unnecessarily invasive and fragile — it requires maintaining a chart fork instead of a small standalone object.
</details>

---

### Question 6
You edited one of Kyverno's shipped ClusterRoles directly to fix a permissions gap. A week later, someone runs `helm upgrade` to pick up a new Kyverno version. What happens to your edit?
*   **A)** It is preserved, because Helm never touches ClusterRole objects.
*   **B)** It is silently overwritten/reverted, because `helm upgrade` reapplies the chart's version of every templated resource, including that ClusterRole.
*   **C)** The upgrade fails with a conflict error, forcing a manual merge.
*   **D)** Kyverno automatically detects the manual edit and converts it into an aggregated ClusterRole for you.

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: B**

*   **Why B is correct:** `helm upgrade` reapplies every resource the chart templates, including Kyverno's shipped ClusterRoles, back to the chart's defined state — silently discarding any out-of-band manual edit. This is exactly why extending permissions via a new, separate ClusterRole (which Helm doesn't manage or overwrite) is the durable approach.
*   **Why others are incorrect:**
    *   *Option A* is wrong — Helm manages every resource it templates, RBAC objects included.
    *   *Option C* is wrong — Helm does not diff for manual out-of-band edits and raise conflicts; it just reapplies its own state.
    *   *Option D* invents an auto-migration feature that does not exist.
</details>

---

### Question 7
What is the fastest way to check whether the background controller's ServiceAccount currently has permission to create `resourcequotas`, without waiting for a `generate` rule to run and inspecting its outcome?
*   **A)** `kubectl get clusterpolicy -o yaml | grep resourcequotas`
*   **B)** `kubectl auth can-i create resourcequotas --as=system:serviceaccount:kyverno:kyverno-background-controller`
*   **C)** `kubectl describe deployment kyverno-background-controller -n kyverno`
*   **D)** `helm get values kyverno -n kyverno`

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: B**

*   **Why B is correct:** `kubectl auth can-i <verb> <resource> --as=<identity>` directly evaluates RBAC for a given identity against a given action — exactly the question being asked — without needing to trigger any actual generate operation or parse logs/events.
*   **Why others are incorrect:**
    *   *Option A* inspects policy YAML, not RBAC state — a policy can reference a resource kind it has no permission to touch.
    *   *Option C* shows Deployment configuration (image, args, replicas), not RBAC.
    *   *Option D* shows Helm values, unrelated to live RBAC evaluation.
</details>
