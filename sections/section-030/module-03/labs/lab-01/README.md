---
estimated_duration: 25m
---

# Webhooks, Failure Policy and Certificates Lab

Status: UNTESTED (written statically, not yet run against a cluster).

Graded lab for the webhooks module. The cluster starts with Kyverno installed at default values, an empty namespace `mission-ops`, the policy `audit-owner-label` and a ConfigMap `lab-baseline` in the `default` namespace. You change how the webhooks select requests, make them fail open and replace the admission controller certificate. The task is in `question.md`; the walkthrough is in `solution.md`.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS008.git -c sections/section-030/module-03/labs/lab-01
astrona submit -c sections/section-030/module-03/labs/lab-01
astrona destroy ats-008-lab-017
```

## Checks

| Script | What it proves |
| --- | --- |
| `validate-webhook-selector.sh` | The `webhooks` key of the `kyverno` ConfigMap holds `mission-ops` and `kube-system`, and the live validating webhook has `mission-ops` in its namespace selector |
| `validate-failure-policy.sh` | The admission controller runs with `--forceFailurePolicyIgnore=true` and no live resource webhook has `failurePolicy: Fail` |
| `validate-certificate.sh` | The certificate in `kyverno-svc.kyverno.svc.kyverno-tls-pair` has a different serial from the one recorded in `lab-baseline` |
| `validate-helm-managed.sh` | The release holds the settings, is at revision 2 or higher and the admission controller has a ready Pod |

The bootstrap script records the starting serial with `openssl`. The grader needs `openssl` on the machine that runs the checks.
