# Section 020: Kyverno Custom Resource Definitions (CRDs)

Kyverno is not a sidecar binary bolted onto Kubernetes — it is a set of Custom Resource Definitions plus controllers that watch them. Every policy you write, every exemption you carve out, and every compliance result you read back is a first-class Kubernetes object, stored in etcd, visible to `kubectl get`, and governed by the same RBAC as anything else in the cluster.

This section is where you stop treating that as a slogan and start treating it as a map. You will learn exactly which CRDs Kyverno registers, split into two families: the ones you author yourself (policies, exceptions, cleanup rules), and the ones Kyverno's own controllers generate on your behalf (reports). Knowing the difference is what lets you debug a policy that "isn't working" by reading the right object instead of guessing.

---

## What You Will Master

By completing this section, you will acquire four core Kyverno CRD competencies:
*   **The Policy-Authoring Family:** `ClusterPolicy`/`Policy`, `PolicyException`, `CleanupPolicy`/`ClusterCleanupPolicy`, and `GlobalContextEntry` — what each one is for, and which ones you write by hand.
*   **PolicyException Enablement:** Why `PolicyException` is disabled by default, and the exact two admission-controller flags (`--enablePolicyException`, `--exceptionNamespace`) that turn it on and scope who is trusted to author one.
*   **The Reporting Family:** `PolicyReport`/`ClusterPolicyReport` as the end-user-facing results you actually read, versus `AdmissionReport`/`BackgroundScanReport` and `UpdateRequest` as internal, ephemeral plumbing you rarely touch directly.
*   **CRD Discovery:** Using `kubectl get crd | grep kyverno.io` and `kubectl api-resources | grep -i kyverno` to enumerate the full surface Kyverno installs, and `kubectl explain` to read live schema for the version actually running.

---

## The Learning & Lab Path

This section is one module, paired with a dedicated graded lab on a kind Kubernetes cluster, followed by a Section Capstone Challenge:

### 1. Kyverno's CRD Surface
*   **Module Reader:** **[Module 1: Kyverno's CRD Surface](./module-01/course.md)**
    1. [Policy-Authoring CRDs](./module-01/course-01-policy-authoring-crds.md)
    2. [Reporting & State CRDs](./module-01/course-02-reporting-and-state-crds.md)
*   **Practice Lab Sandbox:** **`sections/section-020/module-01/labs/lab-01`**
*   **Lab Run Command:**
    ```bash
    astrona run --git git@github.com:astrona-io/ATS008.git -c sections/section-020/module-01/labs/lab-01
    ```
*   **Hands-on Objective:** Enable `PolicyException` on a running admission controller, author one that exempts a specific Pod from an existing `ClusterPolicy`, and confirm it is admitted while an unexempted Pod is still blocked.

### 2. Section Capstone Challenge
*   **Comprehensive Challenge:** **`sections/section-020/capstone/labs/lab-01` (Kyverno CRDs Integration)**
*   **Lab Run Command:**
    ```bash
    astrona run --git git@github.com:astrona-io/ATS008.git -c sections/section-020/capstone/labs/lab-01
    ```
*   **Hands-on Objective:** Author exceptions against two independent policies at once, proving each exemption is scoped correctly and every non-exempt resource is still enforced.

---

## Ready for Assessment?

Test your theoretical knowledge and diagnostic reasoning before tackling the practical lab missions:

*   **[Take the Section 020 Knowledge Check Quiz](./quiz.md)**
