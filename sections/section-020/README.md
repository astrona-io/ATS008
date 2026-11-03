# Section 020: Kyverno Custom Resource Definitions (CRDs)

Kyverno is a set of Custom Resource Definitions and controllers that watch them. Every policy you write, every waiver you sign and every report you read is a Kubernetes object. This section maps those objects, shows how to clean up with Kyverno, and teaches you to read the report cards it writes.

## What You Will Master

- **The CRD map:** which kinds you author (`ClusterPolicy`, `Policy`, `PolicyException`, `CleanupPolicy`, `ClusterCleanupPolicy`, `GlobalContextEntry`) and which Kyverno generates (`PolicyReport`, `ClusterPolicyReport`, `EphemeralReport`, `ClusterEphemeralReport`, `UpdateRequest`).
- **PolicyException:** why it is off by default and the two admission controller flags that switch it on.
- **Cleanup policies:** `CleanupPolicy` and `ClusterCleanupPolicy`, the schedule, the `cleanup.kyverno.io/ttl` label and the permission the cleanup controller needs.
- **Policy reports:** `Audit` and `Enforce`, `PolicyReport` and `ClusterPolicyReport`, reading counts and results with `kubectl`, and the intermediate reports and background scan behind them.

## The Learning and Lab Path

Module 1 runs Kyverno v1.13.2 from the release manifest. Modules 2 and 3 run the current Helm chart (chart 3.9.x, Kyverno v1.19.x).

### 1. Kyverno's CRD Surface

- **Module reader:** [Kyverno's CRD Surface](./module-01/course.md)
  1. [The Kyverno CRD Map](./module-01/course-01-the-kyverno-crd-map.md)
  2. [Policy Exceptions](./module-01/course-02-policy-exceptions.md)
  3. [Cleanup Policies and Global Context Entries](./module-01/course-03-cleanup-policies-and-global-context.md)
  4. [Generated CRDs: Reports and Queues](./module-01/course-04-generated-crds-reports-and-queues.md)
  5. [Summary](./module-01/course-05-summary.md)
- **Playground:** `ats-008-playground-020-01`
- **Lab:** `ats-008-lab-003` in `sections/section-020/module-01/labs/lab-01`
  ```bash
  astrona run --git ssh://git@github.com/astrona-io/ATS008.git -c sections/section-020/module-01/labs/lab-01
  ```
- **Hands-on objective:** switch on `PolicyException`, exempt one Pod and prove another Pod is still blocked.

### 2. Cleaning Up Resources with CleanupPolicy and ClusterCleanupPolicy

- **Module reader:** [Cleaning Up Resources](./module-02/course.md)
  1. [Cleanup Policies: The Salvage Schedule](./module-02/course-01-cleanup-policies-the-salvage-schedule.md)
  2. [The Time-to-Live Label](./module-02/course-02-the-time-to-live-label.md)
  3. [Clearance for the Salvage Crew and Checking That It Ran](./module-02/course-03-clearance-for-the-salvage-crew-and-checking-it-ran.md)
  4. [Summary](./module-02/course-04-summary.md)
- **Playground:** `ats-008-playground-020-02`
- **Lab:** `ats-008-lab-014` in `sections/section-020/module-02/labs/lab-01`
  ```bash
  astrona run --git ssh://git@github.com/astrona-io/ATS008.git -c sections/section-020/module-02/labs/lab-01
  ```
- **Hands-on objective:** give the cleanup controller permission to delete ConfigMaps and write a `CleanupPolicy` that removes labelled ConfigMaps every minute.

### 3. Reading Policy Reports and Intermediate Reports

- **Module reader:** [Reading Policy Reports and Intermediate Reports](./module-03/course.md)
  1. [Audit and Enforce, and the Report Kinds](./module-03/course-01-audit-enforce-and-the-report-kinds.md)
  2. [Reading Results with kubectl](./module-03/course-02-reading-results-with-kubectl.md)
  3. [Background Scans and Intermediate Reports](./module-03/course-03-background-scans-and-intermediate-reports.md)
  4. [Summary](./module-03/course-04-summary.md)
- **Playground:** `ats-008-playground-020-03`
- **Lab:** `ats-008-lab-015` in `sections/section-020/module-03/labs/lab-01`
  ```bash
  astrona run --git ssh://git@github.com/astrona-io/ATS008.git -c sections/section-020/module-03/labs/lab-01
  ```
- **Hands-on objective:** read the live reports and write the failing Deployments, the failed result count, the failing Namespace and the failure action to a ConfigMap.

### 4. Section Capstone Challenge

- **Challenge:** `ats-008-lab-004` in `sections/section-020/capstone/labs/lab-01` (Kyverno CRDs Integration)
  ```bash
  astrona run --git ssh://git@github.com/astrona-io/ATS008.git -c sections/section-020/capstone/labs/lab-01
  ```
- **Hands-on objective:** write exceptions against two independent policies and prove each one is scoped correctly.

## Ready for Assessment?

Test yourself with the [Section 020 knowledge check](./quiz.yaml). It has twelve questions across the three modules.

All new labs in this section are untested: they were written without running them against a cluster.
