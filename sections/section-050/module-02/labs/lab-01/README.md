---
estimated_duration: 25m
---

# Sizing and Spreading Kyverno Lab

Status: UNTESTED (written statically, not yet run against a cluster).

Graded lab for the sizing, disruption budgets and spreading module. The cluster starts with the `kyverno` Helm repository added and Kyverno not installed. You install it with a values file. The task is in `question.md`; the walkthrough is in `solution.md`.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS008.git -c sections/section-050/module-02/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS008.git -c sections/section-050/module-02/labs/lab-01
astrona destroy ats-008-lab-019
```

## Checks

| Script | What it proves |
| --- | --- |
| `validate-replicas.sh` | The Deployments show 3 admission and 2 background replicas, all ready |
| `validate-pdb.sh` | The admission budget has `maxUnavailable: 1`, no `minAvailable`, and allows 1 disruption; the background budget keeps 1 Pod |
| `validate-spread.sh` | The admission Deployment has the spread rule and priority class |

The checks read the live objects. They do not test scheduling over several nodes, because the cluster has one node.
