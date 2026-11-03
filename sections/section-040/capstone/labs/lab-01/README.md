---
estimated_duration: 20m
---

# Kyverno RBAC Capstone Lab

Section 040 capstone. Kyverno is installed by Helm with the `ClusterPolicy` `generate-network-policy`, and the chart's default permission for the background controller to create `NetworkPolicy` objects is removed. You fix a `generate` rule that cannot build `NetworkPolicy` objects with a new, labelled ClusterRole. The task is in `question.md`; the walkthrough is in `solution.md`.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS008.git -c sections/section-040/capstone/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS008.git -c sections/section-040/capstone/labs/lab-01
astrona destroy ats-008-lab-008
```
