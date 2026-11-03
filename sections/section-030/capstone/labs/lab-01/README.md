---
estimated_duration: 25m
---

# Controller Configuration with Flags Capstone Lab

Graded capstone for the controller flags section. The cluster starts with Kyverno installed with Helm at default values. In one values file and one `helm upgrade`, you set flags on the admission controller and on the cleanup controller, which have different value paths. The task is in `question.md`; the walkthrough is in `solution.md`.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS008.git -c sections/section-030/capstone/labs/lab-01
astrona submit -c sections/section-030/capstone/labs/lab-01
astrona destroy ats-008-lab-006
```

## Checks

| Script | What it proves |
| --- | --- |
| `validate-admission.sh` | The admission Deployment runs with `--webhookTimeout=15`, `--enablePolicyException=true` and `--exceptionNamespace=capstone-030` |
| `validate-cleanup.sh` | The cleanup Deployment runs with `--ttlReconciliationInterval=5m` |
