---
estimated_duration: 20m
---

# ClusterRole Aggregation Lab

Graded lab for the RBAC module. The cluster starts with Kyverno installed by Helm and the `ClusterPolicy` `generate-default-quota`. The chart's default permission for the background controller to create `ResourceQuota` objects is removed, so new namespaces get no quota. You grant the permission with a new ClusterRole that carries the aggregation label. The task is in `question.md`; the walkthrough is in `solution.md`.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS008.git -c sections/section-040/module-01/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS008.git -c sections/section-040/module-01/labs/lab-01
astrona destroy ats-008-lab-007
```

Authors run the local copy with `astrona run -c <lab>`.
