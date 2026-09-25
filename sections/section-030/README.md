# Section 030: Controller Configuration with Flags

"Kyverno" is not one process — it is four. Behind the single Helm release you installed in Section 010 sit four independent controller Deployments, each its own binary, each with its own set of command-line flags, and each tuned for a different job: admitting live requests, running background scans, aggregating reports, and cleaning up expired resources. Treating them as one undifferentiated blob is how you end up tuning the wrong knob and wondering why nothing changed.

This section teaches you to read and set those flags directly — both by inspecting a live Deployment's `args` and by changing them the supported way, through Helm.

---

## What You Will Master

By completing this section, you will acquire four core competencies:
*   **The Four Controllers:** Which controller does what — admission, background, reports, cleanup — and the key flags each one exposes for timeouts, concurrency, scan intervals, and rate limiting.
*   **Live Flag Inspection:** Reading a controller's actual running arguments straight off its Deployment with `kubectl get deploy ... -o jsonpath`, rather than guessing from documentation alone.
*   **The extraArgs Helm Pattern:** Setting controller flags through Helm's `extraArgs` values — and the inconsistent nesting between the admission controller (`admissionController.container.extraArgs`) and the other three (`backgroundController.extraArgs`, `reportsController.extraArgs`, `cleanupController.extraArgs`) that trips up almost everyone the first time.
*   **ConfigMap vs. Flag:** Telling apart settings that live in Kyverno's ConfigMap (often hot-reloaded, no restart) from settings that are container flags (always require a pod roll).

---

## The Learning & Lab Path

This section has one module, paired with a dedicated graded lab on a kind Kubernetes cluster, and concludes with a Capstone Integration Challenge:

### 1. Tuning Kyverno's Controllers with Flags
*   **Module Reader:** **[Module 1: Tuning Kyverno's Controllers with Flags](./module-01/course.md)**
    1. [The Four Controllers & Their Flags](./module-01/course-01-the-four-controllers-and-their-flags.md)
    2. [Setting Flags via Helm](./module-01/course-02-setting-flags-via-helm.md)
*   **Practice Lab Sandbox:** **`sections/section-030/module-01/labs/lab-01`**
*   **Lab Run Command:**
    ```bash
    astrona run --git git@github.com:astrona-io/ATS008.git -c sections/section-030/module-01/labs/lab-01
    ```
*   **Hands-on Objective:** Use `helm upgrade` to set `--genWorkers=5` on the background controller and `--backgroundScanInterval=30m` on the reports controller, then confirm both flags actually landed on the correct live Deployments.

### 2. Section Capstone Challenge
*   **Comprehensive Challenge:** **`sections/section-030/capstone/labs/lab-01` (Controller Configuration Integration)**
*   **Lab Run Command:**
    ```bash
    astrona run --git git@github.com:astrona-io/ATS008.git -c sections/section-030/capstone/labs/lab-01
    ```
*   **Hands-on Objective:** In a single `helm upgrade -f values.yaml`, set `--webhookTimeout=15`, enable and scope `PolicyException` support on the admission controller, and set `--ttlReconciliationInterval=5m` on the cleanup controller — deliberately exercising the extraArgs nesting difference between the two controllers.

---

## Ready for Assessment?

Test your theoretical knowledge and diagnostic reasoning before tackling the practical lab missions:

*   **[Take the Section 030 Knowledge Check Quiz](./quiz.md)**
