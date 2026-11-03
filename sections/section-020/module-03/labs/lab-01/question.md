# Policy Reports Lab

## Scenario

A training solar system runs Kyverno. The planet `shipyard` holds four Deployments. Two `ClusterPolicy` objects run in `Audit` mode and write their findings to report cards. Nobody has read them yet. You are asked to read the live reports and write down what they say. You must not fix anything: the evidence has to stay as it is.

## Tasks

1. Read the `PolicyReport` objects in the namespace `shipyard`. Find the Deployments that have at least one failed result.
2. Add up the failed results over all reports in `shipyard`.
3. Read the `ClusterPolicyReport`. Find the Namespace that fails a rule.
4. Find the `failureAction` of the rules of the `ClusterPolicy` `require-fleet-labels`.
5. Save your answers as a ConfigMap named `report-answers` in `shipyard` with these keys:
   - `failing-deployments`: the failing Deployment names, sorted, comma separated, no spaces.
   - `fail-count`: the total number of failed results as a number.
   - `failing-namespace`: the name of the failing Namespace.
   - `policy-mode`: the failure action.

## Rules

- Do not change the policies or the Deployments.
- Take every answer from the live reports and policies. Do not guess from the Deployment files.

The grader reads the same reports and compares them with your ConfigMap.
