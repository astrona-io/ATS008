# Reading Results with kubectl

A report card is a Kubernetes object, so you read it with `kubectl`. This part shows you how to go from "something fails" to "which object, which rule and how many", using columns and JSONPath. JSONPath is a small language that picks fields out of an object.

## The summary counts

Every report has a `summary` with five counters: `pass`, `fail`, `warn`, `error` and `skip`. They count the results in that one report.

### See it in your playground

<!-- astrona:playground:renew -->

List the report cards on the planet:

```sh
kubectl get policyreport -n hangar
```

The columns `KIND`, `NAME`, `PASS` and `FAIL` come from `scope` and `summary`. Each line is one object. A line with a non-zero `FAIL` is a Deployment that broke a rule. The report name is a long identifier: the UID of the checked object. Reports can take a moment to appear. Run the command again if the list is empty.

## From summary to detail

The counts tell you that something fails. The `results` list tells you what. Print one line per report, with the object name and the failures:

```sh
kubectl get policyreport -n hangar -o jsonpath='{range .items[*]}{.scope.kind}{" "}{.scope.name}{" fail="}{.summary.fail}{"\n"}{end}'
```

Each line shows the kind, the name and the fail counter of one checked object. Compare it with the Deployments in `hangar`. Now list every failed result with its policy and rule:

```sh
kubectl get policyreport -n hangar -o jsonpath='{range .items[*]}{range .results[?(@.result=="fail")]}{.policy}{" "}{.rule}{" "}{.message}{"\n"}{end}{end}'
```

The filter `?(@.result=="fail")` keeps only failed results. A result also holds `category`, `severity`, `scored`, `source` and `timestamp`. The `result` field is one of `pass`, `fail`, `warn`, `error` or `skip`.

## The solar system report

Cluster-scoped objects are in `ClusterPolicyReport`:

```sh
kubectl get clusterpolicyreport -o jsonpath='{range .items[*]}{.scope.kind}{" "}{.scope.name}{" fail="}{.summary.fail}{"\n"}{end}'
```

Here each line is one Namespace that the policy `require-planet-env` checked. The planet without an `env` label has a non-zero fail count.

## Count and total

To add up the failed results on a planet, sum the `fail` counters. This command prints one number per report, and `awk` adds them:

```sh
kubectl get policyreport -n hangar -o jsonpath='{range .items[*]}{.summary.fail}{"\n"}{end}' | awk '{total += $1} END {print total + 0}'
```

Compare the total with the number of failing Deployments. They can differ: one Deployment with two failing rules adds two to the total but is one object.

## Common pitfalls

> [!WARNING]
> - **Reading only the summary.** `fail=1` does not say which rule failed. Read `results`.
> - **Counting failed results as failed objects.** One object can fail several rules.
> - **Searching by object name.** The report name is the UID of the object. Use `scope.name` instead.
> - **Reading results too early.** The first scan takes a short time. Check again before you decide a report is empty.

## Your mission: Policy Reports Lab

You can now find the right report card, read its summary and results and pull the answers out with JSONPath. The mission starts a fresh solar system with Audit-mode policies and some violating Deployments, and asks you to read the live reports and write your answers to a ConfigMap. You must not fix anything.

Pause your playground first:

```sh
astrona stop ats-008-playground-020-03
```

Start the mission, then grade it when you are done:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS008.git -c sections/section-020/module-03/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS008.git -c sections/section-020/module-03/labs/lab-01
```

When you have finished, remove the mission and bring your playground back:

```sh
astrona destroy ats-008-lab-015
astrona start ats-008-playground-020-03
```
