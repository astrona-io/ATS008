#!/usr/bin/env bash
# Reads the live PolicyReports in shipyard and compares them with the answers in
# the ConfigMap report-answers.

set -u

if ! kubectl get configmap report-answers -n shipyard >/dev/null 2>&1; then
  echo "FAIL: ConfigMap report-answers not found in shipyard"
  exit 1
fi

# Bounded wait until the reports show failures.
expected_list=""
expected_total=0
for i in $(seq 1 24); do
  lines=$(kubectl get policyreport -n shipyard -o jsonpath='{range .items[*]}{.scope.kind}{" "}{.scope.name}{" "}{.summary.fail}{"\n"}{end}' 2>/dev/null)
  expected_list=$(echo "$lines" | awk '$1=="Deployment" && $3>0 {print $2}' | sort | paste -sd, -)
  expected_total=$(echo "$lines" | awk '$1=="Deployment" {t += $3} END {print t + 0}')
  if [[ -n "$expected_list" ]]; then break; fi
  sleep 5
done

if [[ -z "$expected_list" ]]; then
  echo "FAIL: the live PolicyReports in shipyard show no failures; the cluster is not ready"
  exit 1
fi

got_list=$(kubectl get configmap report-answers -n shipyard -o jsonpath='{.data.failing-deployments}' | tr -d ' ')
got_total=$(kubectl get configmap report-answers -n shipyard -o jsonpath='{.data.fail-count}' | tr -d ' ')

if [[ "$got_list" != "$expected_list" ]]; then
  echo "FAIL: failing-deployments is '$got_list' but the live reports show a different set"
  exit 1
fi
if [[ "$got_total" != "$expected_total" ]]; then
  echo "FAIL: fail-count is '$got_total' but the live reports sum to a different number"
  exit 1
fi

echo "PASS: failing Deployments and fail count match the live reports."
exit 0
