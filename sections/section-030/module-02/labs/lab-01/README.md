---
estimated_duration: 20m
---

# The Kyverno ConfigMap Lab

Status: UNTESTED (written statically, not yet run against a cluster).

Graded lab for the Kyverno ConfigMap module. The cluster starts with the `kyverno` Helm repository added, Kyverno installed at default values and an empty namespace named `mission-ops`. You change the Kyverno ConfigMap through Helm values and check the result. The task is in `question.md`; the walkthrough is in `solution.md`.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS008.git -c sections/section-030/module-02/labs/lab-01
astrona submit -c sections/section-030/module-02/labs/lab-01
astrona destroy ats-008-lab-016
```

## Checks

| Script | What it proves |
| --- | --- |
| `validate-exclude.sh` | `excludeUsernames` in the `kyverno` ConfigMap holds `system:serviceaccount:mission-ops:flight-bot`, and `excludeGroups` still holds `system:nodes` |
| `validate-events.sh` | `generateSuccessEvents` is `true` |
| `validate-filters.sh` | `resourceFilters` holds `[*/*,mission-ops,*]` and still holds the default entries `[Event,*,*]`, `[Node,*,*]`, `[*/*,kube-system,*]` and `[*/*,kube-public,*]` |
| `validate-helm-managed.sh` | The manifest stored in the Helm release holds the three settings, and the release is at revision 2 or higher |
