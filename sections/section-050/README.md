# Section 050: High Availability Installations

Every earlier section installed Kyverno with a single replica per controller — fine for a lab, dangerous for production. A cluster's admission webhook sitting behind exactly one Pod means a single node drain, OOM kill, or rolling restart can leave every `kubectl apply` in the cluster hanging on a webhook timeout. This section is about closing that gap correctly.

The trap is assuming "high availability" means the same thing for every Kyverno controller. It does not. Kyverno ships four controllers, and only one of them gets more *throughput* from more replicas — the other three only get *failover*. Get that distinction backwards and you'll either under-provision the controller that actually needs headroom, or waste resources scaling one that was never going to use them.

---

## What You Will Master

By completing this section, you will acquire the following core Kyverno competencies:
*   **Per-Controller Replica Semantics:** Why the admission controller scales horizontally with no leader election for its core traffic, while the background, reports, and cleanup controllers rely on leader election — meaning only one replica ever does the real work, however many you run.
*   **The Documented HA Install Command:** The exact `helm install` shape Kyverno's own docs recommend for production (`admissionController.replicas=3`, `backgroundController.replicas=2`, `cleanupController.replicas=2`, `reportsController.replicas=2`), and why those numbers differ per controller.
*   **Inspecting Leader Election:** Using Kubernetes `Lease` objects (`kubectl get lease -n kyverno`) to see which replica currently holds leadership for a leader-elected controller.
*   **General HA Hygiene:** Spreading replicas across nodes so a single node failure can't take out every copy of a controller at once.

---

## The Learning & Lab Path

This section is divided into one module, paired with a dedicated graded lab on a kind Kubernetes cluster, and concludes with a Capstone Integration Challenge:

### 1. Running Kyverno Highly Available
*   **Module Reader:** **[Module 1: Running Kyverno Highly Available](./module-01/course.md)**
    1. [Why Replicas Behave Differently Per Controller](./module-01/course-01-why-replicas-behave-differently.md)
    2. [Installing for HA with Helm](./module-01/course-02-installing-for-ha-with-helm.md)
*   **Practice Lab Sandbox:** **`sections/section-050/module-01/labs/lab-01`**
*   **Lab Run Command:**
    ```bash
    astrona run --git git@github.com:astrona-io/ATS008.git -c sections/section-050/module-01/labs/lab-01
    ```
*   **Hands-on Objective:** Install Kyverno via Helm with the documented HA replica counts (3/2/2/2), then confirm leader election is active via `Lease` objects and that all three admission-controller replicas are Running.

### 2. Section Capstone Challenge
*   **Comprehensive Challenge:** **`sections/section-050/capstone/labs/lab-01` (High Availability Installations Integration)**
*   **Lab Run Command:**
    ```bash
    astrona run --git git@github.com:astrona-io/ATS008.git -c sections/section-050/capstone/labs/lab-01
    ```
*   **Hands-on Objective:** Combine HA replica counts with right-sized admission-controller resource requests in a single Helm install, then verify both together.

---

## Ready for Assessment?

Test your theoretical knowledge and diagnostic reasoning before tackling the practical lab missions:

*   **[Take the Section 050 Knowledge Check Quiz](./quiz.md)**
