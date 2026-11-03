# Section 030: Controller Configuration with Flags

Kyverno is not one program. Behind the single Helm release sit four controller Deployments, and each one has its own command-line flags. Kyverno also has a ConfigMap that all four read live, and a set of webhooks and certificates that connect the admission controller to the API server. This section shows you how to read each of these on a running cluster and how to change them the supported way, through Helm values.

---

## What You Will Master

- **The four controllers and their flags.** Which controller does what, which flags it exposes, and how to read the live `args` of a Deployment.
- **The extraArgs map.** How to set flags in Helm, including the nesting difference between the admission controller (`admissionController.container.extraArgs`) and the other three (`<controller>.extraArgs`).
- **The Kyverno ConfigMap.** Which `config.*` values become keys, how to exclude users and groups, how to add to the resource filters without losing the defaults, and why a ConfigMap change needs no restart.
- **Webhooks and failure policy.** How Kyverno writes its webhook configurations, what `Fail` and `Ignore` mean, and what `forceFailurePolicyIgnore` changes.
- **Webhook selectors and timeout.** How `config.webhooks` and `--webhookTimeout` decide which launches use the webhooks.
- **Webhook certificates.** The two TLS secrets, the three ways to manage them, and how to replace a certificate and prove it.

---

## The Learning & Lab Path

The section has three modules. Each module has its own playground and one graded lab, and the section ends with a capstone.

### 1. Tuning Kyverno Controllers with Flags

*   **Module reader:** [Module 1](./module-01/course.md)
    1. [The Four Controllers & Their Flags](./module-01/course-01-the-four-controllers-and-their-flags.md)
    2. [Setting Flags with Helm](./module-01/course-02-setting-flags-with-helm.md)
    3. [Summary](./module-01/course-03-summary.md)
*   **Playground:** `ats-008-playground-030-01` (Kyverno at default values)
*   **Graded lab:** `sections/section-030/module-01/labs/lab-01` (`ats-008-lab-005`)
    ```bash
    astrona run --git ssh://git@github.com/astrona-io/ATS008.git -c sections/section-030/module-01/labs/lab-01
    ```
*   **Hands-on objective:** Use `helm upgrade` to set `--genWorkers=5` on the background controller and `--backgroundScanInterval=30m` on the reports controller, then confirm both flags on the live Deployments.

### 2. The Kyverno ConfigMap

*   **Module reader:** [Module 2](./module-02/course.md)
    1. [Reading the Kyverno ConfigMap](./module-02/course-01-reading-the-kyverno-configmap.md)
    2. [Changing the ConfigMap with Helm](./module-02/course-02-changing-the-configmap-with-helm.md)
    3. [Summary](./module-02/course-03-summary.md)
*   **Playground:** `ats-008-playground-030-02` (Kyverno at default values and an empty namespace `mission-ops`)
*   **Graded lab:** `sections/section-030/module-02/labs/lab-01` (`ats-008-lab-016`)
    ```bash
    astrona run --git ssh://git@github.com/astrona-io/ATS008.git -c sections/section-030/module-02/labs/lab-01
    ```
*   **Hands-on objective:** Exclude one service account, turn on success events and add `mission-ops` to the resource filters through Helm values, keeping every default entry, then prove it on the live ConfigMap and in the Helm release.

### 3. Webhooks, Failure Policy and Certificates

*   **Module reader:** [Module 3](./module-03/course.md)
    1. [Webhook Configurations and Failure Policy](./module-03/course-01-webhook-configurations-and-failure-policy.md)
    2. [Choosing Which Launches Use the Webhooks](./module-03/course-02-choosing-which-launches-use-the-webhooks.md)
    3. [Certificates for the Webhooks](./module-03/course-03-certificates-for-the-webhooks.md)
    4. [Summary](./module-03/course-04-summary.md)
*   **Playground:** `ats-008-playground-030-03` (Kyverno at default values, `mission-ops` and the policy `audit-owner-label`)
*   **Graded lab:** `sections/section-030/module-03/labs/lab-01` (`ats-008-lab-017`)
    ```bash
    astrona run --git ssh://git@github.com/astrona-io/ATS008.git -c sections/section-030/module-03/labs/lab-01
    ```
*   **Hands-on objective:** Make the webhooks skip `mission-ops` while they keep skipping `kube-system`, make them fail open, and replace the admission controller certificate, then prove each change on the live cluster.

### 4. Section Capstone Challenge

*   **Capstone lab:** `sections/section-030/capstone/labs/lab-01` (`ats-008-lab-006`, Controller Configuration Integration)
    ```bash
    astrona run --git ssh://git@github.com/astrona-io/ATS008.git -c sections/section-030/capstone/labs/lab-01
    ```
*   **Hands-on objective:** In a single `helm upgrade -f values.yaml`, set `--webhookTimeout=15` and enable and scope `PolicyException` support on the admission controller, and set `--ttlReconciliationInterval=5m` on the cleanup controller, so that you use both `extraArgs` nestings.

---

## Ready for Assessment?

Test your understanding before you start the missions:

*   **[Take the Section 030 Knowledge Check Quiz](./quiz.yaml)** (12 questions, 4 per module)
