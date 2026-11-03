# Section 050: High Availability Installations

Every earlier section installed Kyverno with one replica per controller. That is fine for a lab and dangerous in production. If the inspectors at the launch gate (the admission controller) run as a single ship, one restart or one node failure can leave every `kubectl apply` waiting on a webhook that does not answer.

The trap is thinking that "high availability" means the same for all four controllers. It does not. Only the admission controller gets more throughput from more replicas. The other controllers get failover. On top of the replica count, a highly available install needs the right sizes, a PodDisruptionBudget and a plan for spreading the ships over nodes.

---

## What You Will Master

*   **Per-controller replica meaning:** Why admission replicas all answer requests, while background and reports replicas stand by behind a lease holder, and what the cleanup controller does.
*   **The HA install:** A `helm install` with a replica count per controller, and what the chart adds for you (a PodDisruptionBudget and a soft anti-affinity).
*   **Sizing:** The replica and resource keys per controller, the chart defaults and Kyverno's scaling guidance.
*   **Leases and drains:** Reading `kubectl get lease -n kyverno` and what a node drain does to a lease holder.
*   **Disruption and spreading:** `podDisruptionBudget`, `topologySpreadConstraints` and `priorityClassName`, checked on the live objects.

---

## The Learning & Lab Path

### 1. Running Kyverno Highly Available
*   **Module reader:** [Running Kyverno Highly Available](./module-01/course.md)
    1. [Why Replicas Behave Differently Per Controller](./module-01/course-01-why-replicas-behave-differently.md)
    2. [Installing for HA with Helm](./module-01/course-02-installing-for-ha-with-helm.md)
    3. [Summary](./module-01/course-03-summary.md)
*   **Playground:** `ats-008-playground-050-01` (Helm repository added, Kyverno not installed)
*   **Lab:** `sections/section-050/module-01/labs/lab-01` (`ats-008-lab-009`)
*   **Run it:**
    ```bash
    astrona run --git ssh://git@github.com/astrona-io/ATS008.git -c sections/section-050/module-01/labs/lab-01
    ```

### 2. Sizing, Disruption Budgets and Spreading Replicas
*   **Module reader:** [Sizing, Disruption Budgets and Spreading Replicas](./module-02/course.md)
    1. [Sizing Replicas and Resources](./module-02/course-01-sizing-replicas-and-resources.md)
    2. [Leases and What a Node Drain Does](./module-02/course-02-leases-and-what-a-node-drain-does.md)
    3. [Disruption Budgets and Spreading Replicas](./module-02/course-03-disruption-budgets-and-spreading-replicas.md)
    4. [Summary](./module-02/course-04-summary.md)
*   **Playground:** `ats-008-playground-050-02` (Kyverno installed at default values)
*   **Lab:** `sections/section-050/module-02/labs/lab-01` (`ats-008-lab-019`)
*   **Run it:**
    ```bash
    astrona run --git ssh://git@github.com/astrona-io/ATS008.git -c sections/section-050/module-02/labs/lab-01
    ```

### 3. Section Capstone
*   **Lab:** `sections/section-050/capstone/labs/lab-01` (`ats-008-lab-010`): HA replica counts and right-sized admission requests in a single Helm install.
*   **Run it:**
    ```bash
    astrona run --git ssh://git@github.com/astrona-io/ATS008.git -c sections/section-050/capstone/labs/lab-01
    ```

Every playground and the new lab are written statically and not yet run against a cluster.

---

## Ready for Assessment?

*   **[Take the Section 050 knowledge check (`quiz.yaml`)](./quiz.yaml)**
