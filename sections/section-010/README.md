# Section 010: Helm-based Installation and Configuration

Welcome to the first section of the **Installation, Configuration, and Upgrades** domain. Before you can write a single `ClusterPolicy`, something has to actually put Kyverno on the cluster — and the way most real clusters do that is Helm: add the chart repo, run a values-driven `helm install`, and get four controllers, a webhook configuration, and a full family of CRDs in one shot.

This section is about doing that deliberately rather than by accident. You will learn the one hard rule Kyverno enforces about *where* it lives, how Helm decides whether your CRDs get installed at all, and how to reach into the chart's `values.yaml` to size and configure the install instead of accepting whatever the defaults happen to be.

---

## What You Will Master

By completing this section, you will acquire five core Kyverno installation competencies:
*   **Repo & Baseline Install:** Adding the official `kyverno` Helm repo and running a correct baseline `helm install` into a dedicated namespace.
*   **The Dedicated-Namespace Rule:** Why Kyverno must never be co-located with other applications in the same namespace, and what that protects.
*   **CRD Auto-Management:** How `crds.install` controls whether Helm installs Kyverno's CRDs for you, via a dedicated CRDs chart dependency.
*   **Values Customization:** Reaching `admissionController.replicas`, `admissionController.container.resources`, and the per-controller `enabled` toggles through `--set` flags or a values file.
*   **Auditing an Install:** Using `helm list`, `helm status`, and `helm get values -a` to see exactly what is actually running versus what you think you configured.

---

## The Learning & Lab Path

This section has one module, paired with a dedicated graded lab on a kind Kubernetes cluster, and concludes with a Capstone Integration Challenge:

### 1. Installing & Configuring Kyverno with Helm
*   **Module Reader:** **[Module 1: Installing & Configuring Kyverno with Helm](./module-01/course.md)**
    1. [Adding the Repo & a Baseline Install](./module-01/course-01-adding-the-repo-and-a-baseline-install.md)
    2. [Customizing the Install: values.yaml & --set](./module-01/course-02-customizing-with-values-and-set.md)
*   **Practice Lab Sandbox:** **`sections/section-010/module-01/labs/lab-01`**
*   **Lab Run Command:**
    ```bash
    astrona run --git git@github.com:astrona-io/ATS008.git -c sections/section-010/module-01/labs/lab-01
    ```
*   **Hands-on Objective:** Install Kyverno via the `kyverno/kyverno` Helm chart into a dedicated `kyverno` namespace, setting `admissionController.replicas=2` and pinning the admission controller's resource requests, then confirm the release and its live configuration.

### 2. Section Capstone Challenge
*   **Comprehensive Challenge:** **`sections/section-010/capstone/labs/lab-01` (Helm-based Installation and Configuration Integration)**
*   **Lab Run Command:**
    ```bash
    astrona run --git git@github.com:astrona-io/ATS008.git -c sections/section-010/capstone/labs/lab-01
    ```
*   **Hands-on Objective:** Install Kyverno from a values file that sets a custom replica count, disables the cleanup controller, and safely extends `config.excludeGroups` without dropping Kyverno's built-in defaults.

---

## Ready for Assessment?

Test your theoretical knowledge and diagnostic reasoning before tackling the practical lab missions:

*   **[Take the Section 010 Knowledge Check Quiz](./quiz.md)**
