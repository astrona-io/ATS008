# Question

Solve this question on: `terminal`

The `checkout` namespace and two `ClusterPolicy` objects are already applied: `require-owner-label` (rule `check-owner-label`, requires an `owner` label on every Pod) and `require-cost-center-label` (rule `check-cost-center-label`, requires a `cost-center` label on every Deployment in `checkout`).

1.  Enable `PolicyException` support on `kyverno-admission-controller` with `--enablePolicyException=true` and `--exceptionNamespace=checkout`, and wait for the rollout.
2.  Author a `PolicyException` named `except-checkout-batch-jobs` in `checkout` that exempts any Pod carrying the label `job-type: batch` from `require-owner-label`'s `check-owner-label` rule.
3.  Author a second `PolicyException` named `except-checkout-nightly-batch` in `checkout` that exempts a Deployment named `nightly-batch` from `require-cost-center-label`'s `check-cost-center-label` rule.
4.  Prove the first exemption: create a Pod named `batch-worker` in `checkout` labeled `job-type: batch` with no `owner` label, and confirm it is admitted.
5.  Prove a control case for the first policy: create a Pod named `unlabeled-worker` in `checkout` with no `job-type` label and no `owner` label, and confirm it is still blocked.
6.  Prove the second exemption: create a Deployment named `nightly-batch` in `checkout` with no `cost-center` label, and confirm it is admitted.
