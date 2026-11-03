---
estimated_duration: 20m
---

# Cleanup Controller Permissions Lab

Status: UNTESTED (written statically, not yet run against a cluster).

Graded lab for the controller permissions module. The cluster starts with Kyverno installed by Helm at default values and the namespace `scrap` with two expired ConfigMaps and one to keep. You give the cleanup controller permission to delete ConfigMaps with a labelled ClusterRole, create a `ClusterCleanupPolicy`, and the expired ConfigMaps disappear. The task is in `question.md`; the walkthrough is in `solution.md`.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS008.git -c sections/section-040/module-02/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS008.git -c sections/section-040/module-02/labs/lab-01
astrona destroy ats-008-lab-018
```

## Checks

| Script | What it proves |
| --- | --- |
| `validate-clusterrole.sh` | A ClusterRole with the cleanup label allows delete on `configmaps`; the shipped `kyverno:cleanup-controller:core` role is unchanged |
| `validate-permission.sh` | `can-i` as the cleanup service account: delete `configmaps` in `scrap` is `yes`, `secrets` and `pods` are `no` |
| `validate-policy.sh` | `ClusterCleanupPolicy` `purge-expired-notes` exists with a schedule and matches ConfigMaps in `scrap` with the label `expired` |
| `validate-effect.sh` | `old-note-1` and `old-note-2` are gone (polls up to 180 seconds) and `keep-note` remains |
