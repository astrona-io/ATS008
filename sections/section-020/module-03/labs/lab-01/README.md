---
estimated_duration: 20m
---

# Policy Reports Lab

Status: UNTESTED (written statically, not yet run against a cluster).

Graded mission for the policy report module. The cluster starts with Kyverno installed with Helm at default values, the namespaces `shipyard` and `drydock`, two `Audit` `ClusterPolicy` objects and four Deployments in `shipyard`. You read the live reports and write your answers to a ConfigMap. The task is in `question.md`; the walkthrough is in `solution.md`.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS008.git -c sections/section-020/module-03/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS008.git -c sections/section-020/module-03/labs/lab-01
astrona destroy ats-008-lab-015
```

Authors run the local copy with `astrona run -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-evidence.sh` | The policies are still `Audit` and the violating Deployments are unchanged |
| `validate-deployments.sh` | `failing-deployments` and `fail-count` in `report-answers` match the live `PolicyReport` objects in `shipyard` |
| `validate-namespace-mode.sh` | `failing-namespace` and `policy-mode` match the live `ClusterPolicyReport` and the policy |
