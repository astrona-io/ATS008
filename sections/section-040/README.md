# Section 040: Configuring Kyverno RBAC, Roles, and Permissions

Kyverno inspects, mutates, generates and cleans up objects across a cluster, so the permissions it runs with matter as much as the policies you write. This section opens up Kyverno's own RBAC model: the four service accounts its controllers use, the aggregated ClusterRole pattern that builds their permissions, and the safe way to extend them.

Get this wrong and you get one of two failures. A rule cannot do its job because a controller lacks a permission, or a hand-edited default role is overwritten on the next `helm upgrade`. This section teaches how to avoid both.

---

## What you will master

* **Service accounts and aggregated ClusterRoles:** the four controller service accounts, the master ClusterRole of each controller, the `rbac.kyverno.io/aggregate-to-<controller>-controller` labels, and the built-in `view` binding.
* **Granting extra permissions safely:** a new labelled ClusterRole instead of an edit to a shipped role, and a proof with `kubectl auth can-i --as=...`.
* **What each controller may do by default:** the admission, background, reports and cleanup controllers, what each one reads and writes, and what is missing out of the box.
* **When a controller lacks a permission:** the symptoms for cleanup, reports and generate rules, and how to find the controller at fault.
* **Chart values and least privilege:** the `rbac.*` values for each controller, `clusterRole.extraResources` against `coreClusterRole.extraResources`, and an audit of what the controllers hold.

---

## The learning and lab path

### 1. Kyverno's RBAC model

* **Module reader:** [Kyverno's RBAC Model](./module-01/course.md)
    1. [ServiceAccounts, Aggregated ClusterRoles and the View Role](./module-01/course-01-serviceaccounts-and-aggregated-clusterroles.md)
    2. [Granting Extra Permissions Safely](./module-01/course-02-granting-extra-permissions-safely.md)
    3. [Summary](./module-01/course-03-summary.md)
* **Playground:** `ats-008-playground-040-01` (Kyverno installed with Helm, plus the ClusterPolicy `generate-default-quota`)
* **Lab:** `ats-008-lab-007`, `sections/section-040/module-01/labs/lab-01`
* **Lab run command:**
    ```bash
    astrona run --git ssh://git@github.com/astrona-io/ATS008.git -c sections/section-040/module-01/labs/lab-01
    ```
* **Hands-on objective:** find why a generate rule builds no `ResourceQuota`, grant the background controller the missing permission with a new aggregated ClusterRole, and prove it.

### 2. Permissions for the cleanup, reports and admission controllers

* **Module reader:** [Permissions for the Cleanup, Reports and Admission Controllers](./module-02/course.md)
    1. [What Each Controller May Do by Default](./module-02/course-01-what-each-controller-may-do-by-default.md)
    2. [When a Controller Lacks a Permission](./module-02/course-02-when-a-controller-lacks-a-permission.md)
    3. [Chart Values for Permissions and Least Privilege](./module-02/course-03-chart-values-for-permissions-and-least-privilege.md)
    4. [Summary](./module-02/course-04-summary.md)
* **Playground:** `ats-008-playground-040-02` (Kyverno at default values, a `debris` namespace with ConfigMaps, a custom `Beacon` resource and the policy `beacons-need-owner`)
* **Lab:** `ats-008-lab-018`, `sections/section-040/module-02/labs/lab-01`
* **Lab run command:**
    ```bash
    astrona run --git ssh://git@github.com/astrona-io/ATS008.git -c sections/section-040/module-02/labs/lab-01
    ```
* **Hands-on objective:** give the cleanup controller a labelled ClusterRole that lets it delete ConfigMaps, create a cleanup policy, and prove the grant and the effect.

### 3. Section capstone

* **Lab:** `ats-008-lab-008`, `sections/section-040/capstone/labs/lab-01` (Kyverno RBAC capstone)
* **Lab run command:**
    ```bash
    astrona run --git ssh://git@github.com/astrona-io/ATS008.git -c sections/section-040/capstone/labs/lab-01
    ```
* **Hands-on objective:** apply the same pattern to a generate rule that builds `NetworkPolicy` objects, with one integrated task and no step-by-step guidance.

### 4. Knowledge check

* [quiz.yaml](./quiz.yaml): 12 scenario questions across both modules.

---

All labs and the new playgrounds in this section are written but not yet run against a cluster.
