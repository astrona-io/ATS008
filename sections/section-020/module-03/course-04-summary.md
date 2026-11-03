# Summary

Kyverno files its inspection results as report cards. You read them with `kubectl`.

## What you learned

- **Audit and Enforce, and the report kinds.** `failureAction: Audit` records a failed result and lets the request through. `Enforce` refuses it, and a refused request leaves no object to report on. `PolicyReport` holds namespaced objects and `ClusterPolicyReport` holds cluster-scoped ones. See [Audit and Enforce, and the Report Kinds](./course-01-audit-enforce-and-the-report-kinds.md).
- **Reading results.** The `summary` holds `pass`, `fail`, `warn`, `error` and `skip`. The `results` list holds the policy, rule, message and result. JSONPath with a filter picks out failures. See [Reading Results with kubectl](./course-02-reading-results-with-kubectl.md).
- **Background scans and intermediate reports.** The admission controller and the background scan write `EphemeralReport` notes. The reports controller merges them into report cards. The patrol interval defaults to one hour. See [Background Scans and Intermediate Reports](./course-03-background-scans-and-intermediate-reports.md).

## Missions

| Mission | What it asks | Lab name |
| --- | --- | --- |
| Policy Reports Lab | Read the live reports and write which Deployments fail, how many results fail, which Namespace fails and the failure action | `ats-008-lab-015` |

## Check yourself

- A request is blocked by an `Enforce` rule. Does the report show a failure for it? Why?
- Where do you find the result for a Namespace that breaks a rule?
- Which controller merges the scratch notes, and which flag sets the patrol interval?
- Why can the total of failed results be bigger than the number of failing objects?

When you have finished, clean up the playground. List what is running, then destroy it:

```sh
astrona list
astrona destroy ats-008-playground-020-03
```

<!-- astrona:playground:destroy -->
