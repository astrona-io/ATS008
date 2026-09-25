# Section 060 Knowledge Check: Upgrading Kyverno

Test your understanding of the Helm upgrade path, Kyverno's CRD-upgrade behavior, manifest-based upgrade limitations, and pre/post-upgrade validation.

---

## Scenario-Based Questions

### Question 1
You installed Kyverno with `kubectl create -f https://github.com/kyverno/kyverno/releases/download/vOLD/install.yaml`. A new version is out. Can you move to it with `kubectl apply -f https://.../vNEW/install.yaml` as an in-place upgrade?
*   **A)** Yes, `kubectl apply` always reconciles cleanly onto a manifest install regardless of version differences.
*   **B)** No — manifest-based installs have no in-place upgrade path; the documented procedure is to `kubectl delete -f` the exact old manifest first, then `kubectl create -f` the new one.
*   **C)** Yes, but only if you also run `helm upgrade` afterward to finish the job.
*   **D)** No — manifest installs can never be upgraded at all, only reinstalled from scratch with all data lost.

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: B**

*   **Why B is correct:** A manifest install isn't tracked as a release by anything, so there's no in-place upgrade mechanism. The documented path is uninstall with the original manifest, then install the new one fresh.
*   **Why others are incorrect:**
    *   *Option A* risks leaving stale or orphaned resources since `apply` doesn't guarantee a clean transition across manifest versions that removed or renamed objects.
    *   *Option C* invents a hybrid workflow that doesn't apply — a manifest install was never a Helm release to begin with.
    *   *Option D* overstates it — cluster data (policies, etc.) in etcd generally survives as long as CRDs aren't deleted; it's the controller resources that need reinstalling, not necessarily all data.
</details>

---

### Question 2
Most Helm charts place CRDs in a special `crds/` directory that `helm upgrade` never touches, requiring manual `kubectl apply` for CRD schema changes. Does `helm upgrade kyverno kyverno/kyverno` update Kyverno's CRDs automatically?
*   **A)** No — Kyverno follows the same `crds/`-directory convention as most charts, so CRDs need manual reapplication on every upgrade.
*   **B)** Yes — Kyverno's CRDs are shipped as regular templated resources in a dedicated CRD chart dependency rather than the special `crds/` directory, so a normal `helm upgrade` does pick up CRD schema changes.
*   **C)** Only if you pass `--set crds.install=true` explicitly on the upgrade command.
*   **D)** Only for `ClusterPolicy`/`Policy`; all other CRDs still require manual reapplication.

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: B**

*   **Why B is correct:** Kyverno deliberately avoids the `crds/`-folder mechanism specifically so CRD schema changes flow through on a normal `helm upgrade`, unlike the common Helm CRD trap most chart users have learned to expect.
*   **Why others are incorrect:**
    *   *Option A* describes the general Helm rule Kyverno specifically does NOT follow.
    *   *Option C* — `crds.install` (default `true`) controls whether Helm manages CRDs at all, not a special extra flag needed on upgrade specifically.
    *   *Option D* is wrong — the behavior applies to Kyverno's whole CRD surface, not a subset.
</details>

---

### Question 3
You're upgrading from an older Kyverno release straight to a much newer one, skipping several minor versions in between, including 1.10. What should you read before running the upgrade?
*   **A)** Only the target version's release notes — intermediate versions don't matter once you're past them.
*   **B)** The release notes for the target version AND every intermediate minor version you're skipping, since Kyverno 1.10 specifically introduced breaking changes that affect upgrades to it or beyond.
*   **C)** Nothing — Helm upgrades are always backward-compatible by design.
*   **D)** Only the Kyverno CLI changelog; Helm chart release notes are unrelated to controller behavior.

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: B**

*   **Why B is correct:** Kyverno's own docs flag 1.10 as introducing breaking changes that limit how upgrades to it, or past it, behave — a multi-version jump can silently walk through breaking changes you'd only catch by reading every intermediate version's notes, not just the final target's.
*   **Why others are incorrect:**
    *   *Option A* is exactly the risk the 1.10 example warns against.
    *   *Option C* is false — Helm faithfully applies whatever a new chart version specifies, breaking changes included.
    *   *Option D* draws a false distinction; the chart's release notes cover the controller behavior changes that matter here.
</details>

---

### Question 4
After a Kyverno upgrade, you notice `PolicyException` objects created under the old version are behaving unexpectedly under the new one due to a stored-schema change. What tool addresses this?
*   **A)** `helm rollback kyverno 1` — always revert instead of fixing forward.
*   **B)** `kyverno migrate --resource policyexceptions.kyverno.io` — the CLI's schema-migration helper for stored objects.
*   **C)** `kubectl delete policyexception --all` — schema issues always mean the objects must be deleted and recreated.
*   **D)** There is no tooling for this; you must hand-edit every affected object's YAML in etcd.

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: B**

*   **Why B is correct:** The Kyverno CLI ships a `migrate` subcommand exactly for bringing stored objects of a given resource type up to date with a new version's schema — this is the documented, supported path.
*   **Why others are incorrect:**
    *   *Option A* is a valid fallback in some situations but not the targeted tool for a known schema-migration case, and it discards the upgrade entirely rather than fixing the specific issue.
    *   *Option C* is destructive and unnecessary when a migration path exists.
    *   *Option D* is wrong — `kyverno migrate` exists precisely to avoid manual etcd surgery.
</details>

---

### Question 5
What is the recommended safety step to take immediately before running any Kyverno upgrade?
*   **A)** Scale the admission controller to 0 replicas so no traffic is processed during the upgrade.
*   **B)** Back up existing `ClusterPolicy`/`Policy` objects, e.g. with `kubectl get clusterpolicy,policy -A -o yaml > policy-backup.yaml`.
*   **C)** Delete all `PolicyReport` objects so the upgrade doesn't have to reconcile old report data.
*   **D)** Disable the background controller entirely until the upgrade completes.

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: B**

*   **Why B is correct:** A quick policy backup costs almost nothing and gives you an exact reference point to diff against or reapply from if anything about the upgrade goes wrong — standard pre-upgrade hygiene.
*   **Why others are incorrect:**
    *   *Option A* would cause an outage in admission processing, which is the opposite of a safe upgrade practice — Kyverno's controllers handle rolling upgrades without you manually scaling to zero.
    *   *Option C* is unnecessary and destructive — reports aren't part of the upgrade risk this checklist is guarding against.
    *   *Option D* is not part of the documented safety checklist and needlessly disables real functionality during the upgrade window.
</details>

---

### Question 6
Immediately after running `helm upgrade kyverno kyverno/kyverno -n kyverno ...`, what combination of commands most directly confirms the upgrade succeeded and the cluster is healthy?
*   **A)** `kubectl get clusterpolicy` only — if policies still list, the upgrade succeeded.
*   **B)** `helm status kyverno -n kyverno` / `helm history kyverno -n kyverno` to confirm the release revision incremented, plus `kubectl rollout status deployment/... -n kyverno` and `kubectl get pods -n kyverno` to confirm every controller actually came back up healthy.
*   **C)** `helm search repo kyverno/kyverno --versions` — confirming the chart version exists in the repo proves the upgrade applied.
*   **D)** Nothing is needed; `helm upgrade` returning exit code 0 is a complete guarantee of a healthy cluster.

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: B**

*   **Why B is correct:** `helm status`/`helm history` confirm the release itself moved to a new revision, while `kubectl rollout status` and `kubectl get pods` confirm the actual workloads came back up healthy — checking the release metadata alone doesn't prove the pods are running correctly, and vice versa.
*   **Why others are incorrect:**
    *   *Option A* only proves the CRDs and API are reachable, not that the upgrade landed or that controllers are healthy.
    *   *Option C* only confirms a chart version exists in the repo you added — it says nothing about whether you actually upgraded to it.
    *   *Option D* is false — `helm upgrade` can report success at the Helm-release level while a Deployment still fails to roll out (e.g. `ImagePullBackOff`), which only `kubectl rollout status`/`get pods` would catch.
</details>

---

### Question 7
Why is Helm the recommended installation method partly *because* of upgrade behavior, not just install-time convenience?
*   **A)** Helm charts are always smaller downloads than raw manifests, which matters for upgrade speed.
*   **B)** A Helm release supports genuine in-place `helm upgrade` with automatic CRD updates via its dedicated CRD chart dependency, while a manifest install requires a full uninstall-then-reinstall with a real availability gap.
*   **C)** Helm is the only installation method that lets you set `admissionController.replicas` at all.
*   **D)** Manifest installs cannot ever be uninstalled, so Helm is required to remove Kyverno cleanly.

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: B**

*   **Why B is correct:** This module's core contrast: Helm gives you a real in-place upgrade path with automatic CRD handling, while the manifest path forces a genuine uninstall/reinstall cycle with a real gap in availability — a meaningful operational difference, not just a convenience preference at install time.
*   **Why others are incorrect:**
    *   *Option A* is not the reason given anywhere in Kyverno's guidance and isn't the operationally significant factor here.
    *   *Option C* is false — a manifest install's controller args can still be hand-edited; Helm just makes it declarative and repeatable, it isn't the only way to set a replica count.
    *   *Option D* is false — `kubectl delete -f <manifest>` uninstalls a manifest-based install just fine; the issue is upgrade behavior, not removability.
</details>
