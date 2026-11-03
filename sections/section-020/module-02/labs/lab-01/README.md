---
estimated_duration: 25m
---

# Cleanup Policy Lab

Status: UNTESTED (written statically, not yet run against a cluster).

Graded mission for the cleanup module. The cluster starts with Kyverno installed with Helm at default values, and the namespaces `salvage-yard` and `outpost`. You give the cleanup controller clearance to delete ConfigMaps and write a `CleanupPolicy` that removes labelled ConfigMaps every minute. The task is in `question.md`; the walkthrough is in `solution.md`.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS008.git -c sections/section-020/module-02/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS008.git -c sections/section-020/module-02/labs/lab-01
astrona destroy ats-008-lab-014
```

Authors run the local copy with `astrona run -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-policy.sh` | `CleanupPolicy` `remove-scrap` exists in `salvage-yard`, matches `ConfigMap` and has the schedule `* * * * *` |
| `validate-permission.sh` | `kubectl auth can-i delete configmaps` as the cleanup controller service account answers `yes` |
| `validate-behaviour.sh` | The grader creates one ConfigMap with `scrap=true` in `salvage-yard`, waits up to 200 seconds for it to vanish, and checks that an unlabeled one, one with `scrap=false` and a `scrap=true` one in `outpost` are still there |
