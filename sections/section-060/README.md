# Section 060: Upgrading Kyverno

Kyverno is the inspection authority of your solar system, and no station stays at one design forever. New versions bring fixes, new CRD fields and sometimes breaking changes. This section teaches you to refit the station in orbit with Helm, to return to an earlier design when a refit goes wrong, and to prove after every change that the inspectors are still at the launch gate.

The section has two modules. Each has a playground, which is a free training solar system, and a graded mission. A capstone mission and a quiz close the section.

## What You Will Master

- **The Helm upgrade command:** run `helm upgrade` against an existing release, keep earlier values with `--reuse-values`, and read the release notes for every version you skip.
- **Kyverno's CRDs travel with the release:** a normal `helm upgrade` updates them, unlike charts with a `crds/` folder.
- **Manifest installs:** why an install made from `install.yaml` has no in-place upgrade, and what `kyverno migrate` is for.
- **Checks around an upgrade:** back up policies, then confirm `helm status`, `helm history`, rollouts and Pods.
- **Rolling back:** `helm history`, `helm rollback` and `helm status`, and what a rollback does to CRDs, policies and hooks.
- **Backups and values:** policies and exceptions as YAML, `--reuse-values` against `--reset-values`, Kubernetes version limits and a pre-upgrade checklist.

## The Learning and Lab Path

### 1. Upgrading a Running Kyverno Installation

- **Module reader:** [Upgrading a Running Kyverno Installation](./module-01/course.md)
  1. [The Helm Upgrade Path](./module-01/course-01-the-helm-upgrade-path.md)
  2. [Manifest Upgrades and Post-Upgrade Validation](./module-01/course-02-manifest-upgrades-and-post-upgrade-validation.md)
  3. [Summary](./module-01/course-03-summary.md)
- **Playground:** `ats-008-playground-060-01` (`module-01/playground`): Kyverno installed with Helm at default values, revision 1.
- **Lab:** `ats-008-lab-011` (`sections/section-060/module-01/labs/lab-01`). Upgrade the release with `--reuse-values`, see revision 2 in the history and keep every Pod healthy.

### 2. Rolling Back and Recovering from a Bad Upgrade

- **Module reader:** [Rolling Back and Recovering from a Bad Upgrade](./module-02/course.md)
  1. [Reading the History and Rolling Back](./module-02/course-01-reading-the-history-and-rolling-back.md)
  2. [What a Rollback Keeps, and Backing Up Policies](./module-02/course-02-what-a-rollback-keeps-and-backing-up-policies.md)
  3. [Values, Version Skew and the Pre-Upgrade Checklist](./module-02/course-03-values-version-skew-and-the-pre-upgrade-checklist.md)
  4. [Summary](./module-02/course-04-summary.md)
- **Playground:** `ats-008-playground-060-02` (`module-02/playground`): Kyverno with a broken revision 2, and a running policy in `finance`.
- **Lab (UNTESTED):** `ats-008-lab-020` (`sections/section-060/module-02/labs/lab-01`). Roll the broken release back to revision 1 and prove the admission controller is healthy and the history shows the rollback.

### 3. Section Capstone

- **Capstone lab:** `ats-008-lab-012` (`sections/section-060/capstone/labs/lab-01`). Back up the policies, upgrade replicas and a controller flag in one `helm upgrade`, and prove the existing policy survived.

## Run Commands

```bash
# Playgrounds (free practice, no grading)
astrona run -c sections/section-060/module-01/playground
astrona run -c sections/section-060/module-02/playground

# Labs (graded against the live cluster)
astrona run --git ssh://git@github.com/astrona-io/ATS008.git -c sections/section-060/module-01/labs/lab-01
astrona submit -c sections/section-060/module-01/labs/lab-01
astrona destroy ats-008-lab-011

astrona run --git ssh://git@github.com/astrona-io/ATS008.git -c sections/section-060/module-02/labs/lab-01
astrona submit -c sections/section-060/module-02/labs/lab-01
astrona destroy ats-008-lab-020

astrona run --git ssh://git@github.com/astrona-io/ATS008.git -c sections/section-060/capstone/labs/lab-01
astrona submit -c sections/section-060/capstone/labs/lab-01
astrona destroy ats-008-lab-012
```

## Ready for Assessment?

Test your knowledge with the [Section 060 knowledge check](./quiz.yaml), which has 12 scenario questions.
