---
estimated_duration: 20m
---

# Rolling Back a Bad Kyverno Upgrade Sandbox

Status: UNTESTED (written statically, not yet run against a cluster).

In this mission a refit of the Kyverno station went wrong. Revision 2 of the `kyverno` release points the admission controller at an image that does not exist. You roll the release back to revision 1 and prove that the inspectors at the launch gate are healthy again and that the flight record shows the rollback.

## Launching the Lab

```bash
astrona run --git ssh://git@github.com/astrona-io/ATS008.git -c sections/section-060/module-02/labs/lab-01
astrona submit -c sections/section-060/module-02/labs/lab-01
astrona destroy ats-008-lab-020
```
