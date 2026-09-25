# ATS008 - KCA: Installation, Configuration, and Upgrades

[![Liberapay](https://img.shields.io/badge/Liberapay-Support_Astrona.io-F6C915?logo=liberapay&logoColor=black&style=for-the-badge)](https://liberapay.com/Astrona.io)

Welcome to **ATS008**, a free, hands-on training curriculum built around the **Installation, Configuration, and Upgrades** domain — the operational core a **Kyverno Certified Associate (KCA)** learner needs to actually run Kyverno on a real cluster, not just author policy for one. This is community training material inspired by the open-source [Kyverno project](https://kyverno.io) (a CNCF Sandbox project); it is not an official Linux Foundation or CNCF exam guide, and no specific vendor exam blueprint is claimed or implied.

Writing a `ClusterPolicy` is easy once Kyverno is running correctly. Getting it running correctly — installed with Helm into a dedicated namespace, its CRDs and controllers configured for your cluster, its RBAC scoped safely, its replicas sized for real availability, and its version kept current without breaking live policies — is the part most tutorials skip. This repository does not skip it.

---

## The Symmetrical 1:1:1 Learning Framework

To make learning intuitive, digestible, and robust, this curriculum is built around a symmetrical **1:1:1 educational architecture**:

1.  **The Textbook Lesson (`sections/section-XXX/module-YY/course.md`):** Narrative, book-style chapters written in a warm, expert "teacher's voice" that explain *why* Kyverno behaves the way it does, using real-world metaphors, inline YAML/bash breakdowns, and clear diagrams.
2.  **The Interactive Quiz (`sections/section-XXX/quiz.md`):** A scenario-based theoretical knowledge check testing diagnostic reasoning, complete with collapsible answers and technical explanation keys.
3.  **The Dedicated Laboratory (`sections/section-XXX/module-YY/`, plus a `sections/section-XXX/capstone/` per section):** A live **kind** Kubernetes cluster sandbox launched instantly via the `astrona` CLI, where you install, configure, and upgrade a real Kyverno deployment and validate your cluster's state using automated grading scripts.

---

## Complete Curriculum & Lab Mapping

The training series is divided into **6 main sections** covering **6 focused modules**, **6 graded module labs**, and **6 comprehensive Section Capstone Challenges**:

| Section & Domain | Module & Chapter Reader | Practice Lab | astrona CLI Run Command |
| :--- | :--- | :--- | :--- |
| **010: Helm-based Installation and Configuration** | [M1: Installing Kyverno with Helm](sections/section-010/module-01/course.md) | [lab](sections/section-010/module-01/labs/lab-01) | `astrona run --git git@github.com:astrona-io/ATS008.git -c sections/section-010/module-01/labs/lab-01` |
| | **Section Capstone Challenge** | **[capstone](sections/section-010/capstone/labs/lab-01)** | `astrona run --git git@github.com:astrona-io/ATS008.git -c sections/section-010/capstone/labs/lab-01` |
| **020: Kyverno Custom Resource Definitions (CRDs)** | [M1: Kyverno's CRD Surface](sections/section-020/module-01/course.md) | [lab](sections/section-020/module-01/labs/lab-01) | `astrona run --git git@github.com:astrona-io/ATS008.git -c sections/section-020/module-01/labs/lab-01` |
| | **Section Capstone Challenge** | **[capstone](sections/section-020/capstone/labs/lab-01)** | `astrona run --git git@github.com:astrona-io/ATS008.git -c sections/section-020/capstone/labs/lab-01` |
| **030: Controller Configuration with Flags** | [M1: Tuning Kyverno Controllers with Flags](sections/section-030/module-01/course.md) | [lab](sections/section-030/module-01/labs/lab-01) | `astrona run --git git@github.com:astrona-io/ATS008.git -c sections/section-030/module-01/labs/lab-01` |
| | **Section Capstone Challenge** | **[capstone](sections/section-030/capstone/labs/lab-01)** | `astrona run --git git@github.com:astrona-io/ATS008.git -c sections/section-030/capstone/labs/lab-01` |
| **040: Configuring Kyverno RBAC, Roles, and Permissions** | [M1: Kyverno RBAC — Roles & Permissions](sections/section-040/module-01/course.md) | [lab](sections/section-040/module-01/labs/lab-01) | `astrona run --git git@github.com:astrona-io/ATS008.git -c sections/section-040/module-01/labs/lab-01` |
| | **Section Capstone Challenge** | **[capstone](sections/section-040/capstone/labs/lab-01)** | `astrona run --git git@github.com:astrona-io/ATS008.git -c sections/section-040/capstone/labs/lab-01` |
| **050: High Availability Installations** | [M1: High Availability Installations](sections/section-050/module-01/course.md) | [lab](sections/section-050/module-01/labs/lab-01) | `astrona run --git git@github.com:astrona-io/ATS008.git -c sections/section-050/module-01/labs/lab-01` |
| | **Section Capstone Challenge** | **[capstone](sections/section-050/capstone/labs/lab-01)** | `astrona run --git git@github.com:astrona-io/ATS008.git -c sections/section-050/capstone/labs/lab-01` |
| **060: Upgrading Kyverno** | [M1: Upgrading Kyverno Safely](sections/section-060/module-01/course.md) | [lab](sections/section-060/module-01/labs/lab-01) | `astrona run --git git@github.com:astrona-io/ATS008.git -c sections/section-060/module-01/labs/lab-01` |
| | **Section Capstone Challenge** | **[capstone](sections/section-060/capstone/labs/lab-01)** | `astrona run --git git@github.com:astrona-io/ATS008.git -c sections/section-060/capstone/labs/lab-01` |

---

## How to Navigate This Course

1.  **Enter a Domain Portal:** Navigate into a domain directory, such as `sections/section-010/`, and open its `README.md` to review the section's core competencies.
2.  **Read the Chapters:** Open and read the narrative chapters in order (`module-01/course.md`, then its parts). Focus on the diagrams, YAML/bash breakdowns, and "Try it" checkpoints.
3.  **Test Your Diagnostics:** Open `quiz.md` inside that section and answer its scenario questions. Expand the `<details>` tags to read the teacher's deep-dive explanations.
4.  **Practice the Sandbox:** Run the module lab (e.g., `sections/section-010/module-01/labs/lab-01`) on a live kind cluster to build real install/configure/upgrade muscle memory.
5.  **Conquer the Capstone Challenge:** Boot up the section's **Capstone Challenge Lab**, solve the integration prompts, and run the automated validation suite to confirm your passing state.
6.  **Simulate the Exam:** Once you have completed all 6 modules, open **`sections/final-domain-quiz.md`** and complete the final closed-book domain exam simulator under a time cap to audit your readiness.

---

## Cluster-Native Focus

Every lab in this repository runs on a **kind** (Kubernetes-in-Docker) cluster spun up by the `astrona` CLI — there are no virtual machines, no host-level Linux administration, and no QEMU images. You install, configure, and upgrade a real Kyverno deployment exclusively through `kubectl` and `helm` against a real cluster, exactly as you would against a production one.

---

## Support This Project

ATS008 is free Kyverno training material. If it helped you on your policy-engine journey, consider supporting ongoing work and resource development via [Liberapay](https://liberapay.com/Astrona.io).
