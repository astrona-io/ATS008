# Section 060: Upgrading Kyverno

Every earlier section in this domain ends with a Kyverno cluster running in some particular configuration — a Helm release, a set of values, a handful of controller flags, a policy or two already applied. None of that stays frozen forever. New Kyverno versions ship bug fixes, new CRD fields, and occasionally breaking changes, and someone has to move a live cluster from the old version to the new one without an outage and without silently losing policy behavior along the way.

This section is about that move: the Helm upgrade path Kyverno is built around, the one place where Kyverno's chart quietly does something most Helm charts don't, why a plain-manifest install boxes you into a much rougher upgrade story, and the concrete checklist for backing up and verifying an upgrade before and after you run it.

---

## What You Will Master

By completing this section, you will acquire four core Kyverno competencies:
*   **The Helm Upgrade Command:** Running `helm upgrade` against an existing release to change values, bump chart versions, or adjust flags in place.
*   **The CRD-Upgrade Trap Kyverno Avoids:** Why most Helm charts leave CRDs stale on `helm upgrade`, and why Kyverno's dedicated CRD chart dependency means yours don't.
*   **Why Manifest Installs Can't Upgrade In Place:** The uninstall-then-reinstall procedure required for a `kubectl create -f install.yaml` deployment, and why that's a reason to prefer Helm from Section 010 onward.
*   **Pre- and Post-Upgrade Validation:** Backing up existing policies before you touch anything, then confirming `helm status`/`helm history`, rollout health, and CRD availability afterward — plus the `kyverno migrate` CLI for schema-changed stored objects.

---

## The Learning & Lab Path

This section is a single module paired with a dedicated graded lab on a kind Kubernetes cluster, followed by a Section Capstone Challenge:

### 1. Upgrading a Running Kyverno Installation
*   **Module Reader:** **[Module 1: Upgrading a Running Kyverno Installation](./module-01/course.md)**
    1. [The Helm Upgrade Path](./module-01/course-01-the-helm-upgrade-path.md)
    2. [Manifest Upgrades & Post-Upgrade Validation](./module-01/course-02-manifest-upgrades-and-post-upgrade-validation.md)
*   **Practice Lab Sandbox:** **`sections/section-060/module-01/labs/lab-01`**
*   **Lab Run Command:**
    ```bash
    astrona run --git git@github.com:astrona-io/ATS008.git -c sections/section-060/module-01/labs/lab-01
    ```
*   **Hands-on Objective:** Upgrade a running Kyverno Helm release with `helm upgrade --reuse-values`, confirm the release revision incremented, and confirm the cluster stayed healthy through the change.

### 2. Section Capstone Challenge
*   **Comprehensive Challenge:** **`sections/section-060/capstone/labs/lab-01` (Upgrading Kyverno Integration)**
*   **Lab Run Command:**
    ```bash
    astrona run --git git@github.com:astrona-io/ATS008.git -c sections/section-060/capstone/labs/lab-01
    ```
*   **Hands-on Objective:** Run the full backup-upgrade-verify flow — back up existing ClusterPolicies to a file, upgrade Kyverno's replicas and a controller flag in one `helm upgrade`, then prove the pre-existing policy survived untouched.

---

## Ready for Assessment?

Test your theoretical knowledge and diagnostic reasoning before tackling the practical lab missions:

*   **[Take the Section 060 Knowledge Check Quiz](./quiz.md)**
