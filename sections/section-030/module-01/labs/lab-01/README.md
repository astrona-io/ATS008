---
estimated_duration: 15m
---

# Controller Flag Tuning Lab

Graded lab for the controller flags module. The cluster starts with the `kyverno` Helm repository added and Kyverno installed at default values. You set a flag on the background controller and a flag on the reports controller with `helm upgrade`, then confirm both in the live Deployments. The task is in `question.md`; the walkthrough is in `solution.md`.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS008.git -c sections/section-030/module-01/labs/lab-01
astrona submit -c sections/section-030/module-01/labs/lab-01
astrona destroy ats-008-lab-005
```

## Checks

| Script | What it proves |
| --- | --- |
| `validate-background.sh` | The background Deployment runs with `--genWorkers=5` |
| `validate-reports.sh` | The reports Deployment runs with `--backgroundScanInterval=30m` |
