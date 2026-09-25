# Question

Solve this question on: `terminal`

The `checkout` namespace and a `ClusterPolicy` named `require-owner-label` (rule `check-owner-label`, `validationFailureAction: Enforce`) are already applied — it requires every Pod to carry a non-empty `owner` label.

1.  Confirm the full Kyverno CRD surface with `kubectl get crd | grep kyverno.io`.
2.  Enable `PolicyException` support on the running admission controller: add the `--enablePolicyException=true` and `--exceptionNamespace=checkout` args to the `kyverno-admission-controller` Deployment and wait for it to roll out.
3.  Author a `PolicyException` named `except-checkout-smoke-test` in namespace `checkout` that exempts a Pod named `smoke-test` in `checkout` from the `check-owner-label` rule of `require-owner-label`.
4.  Create a Pod named `smoke-test` in `checkout` with **no** `owner` label, and confirm it is admitted despite the policy.
5.  Create a Pod named `no-owner-pod` in `checkout` with **no** `owner` label, and confirm it is still blocked by the policy.
6.  Inspect `kubectl get policyreport -n checkout` to see the recorded results.
