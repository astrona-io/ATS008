# Section 040: Configuring Kyverno RBAC, Roles, and Permissions

Kyverno is a controller that can inspect, mutate, and generate almost any resource in your cluster — which means the permissions it runs with matter as much as the policies you write. This section opens up Kyverno's own RBAC model: the four ServiceAccounts its controllers run under, the aggregated-ClusterRole mechanism that assembles their effective permissions, and the one correct way to extend those permissions without ever touching Kyverno's shipped default roles.

Get this wrong and you get one of two failure modes: a `generate` rule that silently can't create the resource it's supposed to, or — worse — a hand-edited default role that gets clobbered the moment you next run `helm upgrade`. This section teaches the pattern that avoids both.

---

## What You Will Master

By completing this section, you will acquire two core Kyverno competencies:
*   **ServiceAccounts & Aggregated ClusterRoles:** The four per-controller ServiceAccounts (`kyverno-admission-controller`, `kyverno-background-controller`, `kyverno-reports-controller`, `kyverno-cleanup-controller`), how Kubernetes ClusterRole aggregation assembles each controller's effective permissions from labeled "-core" roles, and the built-in `view` ClusterRole binding that gives read access to namespaced resources.
*   **Granting Extra Permissions Safely:** Why `generate` rules can fail on missing RBAC even when the policy itself is valid, and the correct fix — a brand-new ClusterRole carrying the right `rbac.kyverno.io/aggregate-to-<controller>-controller` label — instead of editing any of Kyverno's shipped default roles.

---

## The Learning & Lab Path

This section is a single module paired with a dedicated graded lab on a kind Kubernetes cluster, and concludes with a Capstone Integration Challenge:

### 1. Kyverno's RBAC Model
*   **Module Reader:** **[Module 1: Kyverno's RBAC Model](./module-01/course.md)**
    1. [ServiceAccounts, Aggregated ClusterRoles & Built-in View Access](./module-01/course-01-serviceaccounts-and-aggregated-clusterroles.md)
    2. [Granting Extra Permissions Safely](./module-01/course-02-granting-extra-permissions-safely.md)
*   **Practice Lab Sandbox:** **`sections/section-040/module-01/labs/lab-01`**
*   **Lab Run Command:**
    ```bash
    astrona run --git git@github.com:astrona-io/ATS008.git -c sections/section-040/module-01/labs/lab-01
    ```
*   **Hands-on Objective:** Diagnose a `generate` rule that can't create a `ResourceQuota` for lack of RBAC on the background controller's ServiceAccount, then fix it with a correctly-labeled, aggregated ClusterRole — without touching any of Kyverno's default roles.

### 2. Section Capstone Challenge
*   **Comprehensive Challenge:** **`sections/section-040/capstone/labs/lab-01` (Kyverno RBAC Integration)**
*   **Lab Run Command:**
    ```bash
    astrona run --git git@github.com:astrona-io/ATS008.git -c sections/section-040/capstone/labs/lab-01
    ```
*   **Hands-on Objective:** Apply the same aggregated-ClusterRole pattern to a `generate` rule targeting `NetworkPolicy` resources, reinforcing that the fix generalizes to any resource kind the background controller needs to touch.

---

## Ready for Assessment?

Test your theoretical knowledge and diagnostic reasoning before tackling the practical lab missions:

*   **[Take the Section 040 Knowledge Check Quiz](./quiz.md)**
