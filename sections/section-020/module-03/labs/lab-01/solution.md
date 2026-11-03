# Solution: Policy Reports Lab

Status: UNTESTED (written statically, not yet run against a cluster).

Work in your shell, in a folder of your choice. Reports can take a short time to appear, so run a command again if a list is empty.

## Step 1: Read the reports in shipyard

```sh
kubectl get policyreport -n shipyard -o jsonpath='{range .items[*]}{.scope.kind}{" "}{.scope.name}{" fail="}{.summary.fail}{"\n"}{end}'
```

Each line is one checked Deployment. Write down the names with a fail above zero. The expected set is `probe`, `relay` and `shuttle`.

## Step 2: Add up the failures

```sh
kubectl get policyreport -n shipyard -o jsonpath='{range .items[*]}{.summary.fail}{"\n"}{end}' | awk '{t += $1} END {print t + 0}'
```

The total counts failed results, not Deployments. The expected total is 4, because `relay` fails two rules.

## Step 3: Read the Namespace result

```sh
kubectl get clusterpolicyreport -o jsonpath='{range .items[*]}{.scope.kind}{" "}{.scope.name}{" fail="}{.summary.fail}{"\n"}{end}'
```

The Namespace with a fail above zero is `drydock`.

## Step 4: Read the failure action

```sh
kubectl get clusterpolicy require-fleet-labels -o jsonpath='{.spec.rules[*].validate.failureAction}'
```

Both rules print `Audit`.

## Step 5: Save the answers

Save this as `report-answers.yaml`:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: report-answers
  namespace: shipyard
data:
  failing-deployments: "probe,relay,shuttle"
  fail-count: "4"
  failing-namespace: "drydock"
  policy-mode: "Audit"
```

Apply it:

```sh
kubectl apply -f report-answers.yaml
```

## Step 6: Grade it

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS008.git -c sections/section-020/module-03/labs/lab-01
```

All three checks should pass. If a check fails, read its message, compare with the live reports, fix the ConfigMap and submit again.
