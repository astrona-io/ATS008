# Overview: Reading Policy Reports (Playground)

This playground runs the **current Kyverno Helm chart** (chart 3.9.x with Kyverno v1.19.x), installed with Helm as release `kyverno`. It has no grading.

## What is in the box

| Item | State |
| --- | --- |
| Namespace `kyverno` | Four controllers, including `kyverno-reports-controller` |
| Namespace `hangar` | Label `env: prod`. Deployments `falcon` (owner and team), `comet` (team), `nova` (none), `pulsar` (owner) |
| Namespace `depot` | No labels |
| `ClusterPolicy` `require-crew-labels` | `Audit`. Rules `check-owner-label` and `check-team-label` for Deployments in `hangar` |
| `ClusterPolicy` `require-planet-env` | `Audit`. Rule `check-env-label` for the namespaces `hangar` and `depot` |

## Helpers

`fail_lines` prints one line per checked Deployment with its fail counter. `failed_results` prints each failed result with policy, rule and message.

```sh
fail_lines() {
  kubectl get policyreport -n hangar -o jsonpath='{range .items[*]}{.scope.name}{" fail="}{.summary.fail}{"\n"}{end}'
}
failed_results() {
  kubectl get policyreport -n hangar -o jsonpath='{range .items[*]}{range .results[?(@.result=="fail")]}{.policy}{" "}{.rule}{"\n"}{end}{end}'
}
```

## Practice tasks

- Run `fail_lines` and match each line to a Deployment.
- Read the `ClusterPolicyReport` and find the Namespace that fails.
- Switch one rule to `Enforce`, try to create a Deployment without labels, and switch it back.
- Look for `EphemeralReport` objects and read the reports controller `args`.
- Label `nova` with `owner` and `team` and watch the fail counter go to zero.
