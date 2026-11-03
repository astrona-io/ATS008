# Section 010: Helm-based Installation and Configuration

Welcome to the first section of the **Installation, Configuration, and Upgrades** domain. Before you can write a single `ClusterPolicy`, something has to put Kyverno on the cluster. Most real clusters use Helm: add the chart repository, run a values-driven `helm install`, and get four controllers, a webhook configuration and a full family of custom resource definitions in one go.

This section is about doing that deliberately. You learn where Kyverno must live, how Helm decides whether the definitions get installed, and how to reach into the chart's `values.yaml`. You also learn the other way in, the release manifest, and the way out: removing Kyverno without leaving debris behind.

---

## What You Will Master

By completing this section, you will acquire these installation competencies:

*   **Repo & Baseline Install:** Adding the official `kyverno` Helm repo and running a correct baseline `helm install` into a dedicated namespace.
*   **The Dedicated-Namespace Rule:** Why Kyverno must never share a namespace with other applications, and what that protects.
*   **CRD Auto-Management:** How `crds.install` controls whether Helm installs Kyverno's definitions.
*   **Values Customization:** Reaching `admissionController.replicas`, `admissionController.container.resources` and the per-controller `enabled` switches with `--set` or a values file.
*   **Auditing an Install:** Using `helm list`, `helm status`, `helm history` and `helm get values -a` to see what really runs.
*   **Manifest Install:** Installing from a pinned `install.yaml` with `kubectl create`, and what that method does not give you.
*   **Clean Removal:** Uninstalling a release, checking for leftover webhook configurations, definitions and the namespace, and cleaning up in a safe order.

---

## The Learning & Lab Path

This section has two modules. Each has a playground (a clean, ungraded cluster to practise in), a graded lab, and a summary page. A capstone closes the section.

### 1. Installing & Configuring Kyverno with Helm

*   **Module Reader:** **[Module 1: Installing & Configuring Kyverno with Helm](./module-01/course.md)**
    1. [Adding the Repo & a Baseline Install](./module-01/course-01-adding-the-repo-and-a-baseline-install.md)
    2. [Customizing the Install: values.yaml & --set](./module-01/course-02-customizing-with-values-and-set.md)
    3. [Re-running and Auditing the Install](./module-01/course-03-re-running-and-auditing-the-install.md)
    4. [Summary](./module-01/course-04-summary.md)
*   **Playground:** `ats-008-playground-010-01` (`kyverno` Helm repository added, Kyverno not installed)
*   **Practice Lab:** **`sections/section-010/module-01/labs/lab-01`** (`ats-008-lab-001`)
*   **Lab Run Command:**
    ```bash
    astrona run --git ssh://git@github.com/astrona-io/ATS008.git -c sections/section-010/module-01/labs/lab-01
    ```
*   **Hands-on Objective:** Install Kyverno via the `kyverno/kyverno` Helm chart into a dedicated `kyverno` namespace, setting `admissionController.replicas=2` and pinning the admission controller's resource requests, then confirm the release and its live configuration.

### 2. Installing from Manifests and Removing Kyverno Cleanly

*   **Module Reader:** **[Module 2: Installing from Manifests and Removing Kyverno Cleanly](./module-02/course.md)**
    1. [Installing from the Release Manifest](./module-02/course-01-installing-from-the-release-manifest.md)
    2. [Uninstalling Kyverno and Cleaning Up](./module-02/course-02-uninstalling-and-cleaning-up.md)
    3. [Choosing Helm or the Manifest](./module-02/course-03-choosing-helm-or-the-manifest.md)
    4. [Summary](./module-02/course-04-summary.md)
*   **Playground:** `ats-008-playground-010-02` (Kyverno installed with Helm, plus the `ClusterPolicy` `require-owner-label`)
*   **Practice Lab:** **`sections/section-010/module-02/labs/lab-01`** (`ats-008-lab-013`)
*   **Lab Run Command:**
    ```bash
    astrona run --git ssh://git@github.com/astrona-io/ATS008.git -c sections/section-010/module-02/labs/lab-01
    ```
*   **Hands-on Objective:** Remove the Kyverno Helm release and every leftover Kyverno webhook configuration, custom resource definition and the `kyverno` namespace, then create an ordinary Pod to prove the cluster is clean.

### 3. Section Capstone Challenge

*   **Comprehensive Challenge:** **`sections/section-010/capstone/labs/lab-01` (Helm-based Installation and Configuration Integration)** (`ats-008-lab-002`)
*   **Lab Run Command:**
    ```bash
    astrona run --git ssh://git@github.com/astrona-io/ATS008.git -c sections/section-010/capstone/labs/lab-01
    ```
*   **Hands-on Objective:** Install Kyverno from a values file that sets a custom replica count, disables the cleanup controller, and safely extends `config.excludeGroups` without dropping Kyverno's built-in defaults.

---

## Ready for Assessment?

Test your knowledge and your diagnostic reasoning before or after the missions:

*   **[Take the Section 010 Knowledge Check Quiz](./quiz.yaml)** (12 scenario questions, pass score 70%)
