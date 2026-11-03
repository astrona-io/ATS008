---
estimated_duration: 20m
---

# Lab: Remove Kyverno Cleanly

Status: UNTESTED (written statically, not yet run against a cluster).

Graded lab for the module on manifest installs and clean removal. The cluster starts with Kyverno installed with Helm as release `kyverno` in the namespace `kyverno`, and with one `ClusterPolicy`, `require-owner-label`, that refuses Pods without an `owner` label. The task is in `question.md`; the walkthrough is in `solution.md`.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS008.git -c sections/section-010/module-02/labs/lab-01
astrona submit -c sections/section-010/module-02/labs/lab-01
astrona destroy ats-008-lab-013
```

Authors run the local copy with `astrona run -c <lab>` and check the config with `astrona validate -c <lab>`.

## Checks

Every script looks only at the end state of the live cluster, so the result is the same whichever objects Helm removes itself.

| Script | What it proves |
| --- | --- |
| `validate-release-removed.sh` | `helm list -A --all` shows no release named `kyverno` |
| `validate-webhooks-removed.sh` | No validating or mutating webhook configuration has `kyverno` in its name |
| `validate-crds-removed.sh` | No custom resource definition ends in `kyverno.io` (the `wgpolicyk8s.io` report definitions are not checked) |
| `validate-namespace-removed.sh` | The `kyverno` namespace is gone, not only `Terminating` (waits up to 90 seconds) |
| `validate-pod-creation.sh` | A Pod without an `owner` label is accepted in `default` (retries for up to 60 seconds) |
