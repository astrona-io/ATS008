#!/usr/bin/env bash
# Reads the live ClusterPolicyReport and the policy, and compares them with the
# answers in the ConfigMap report-answers.

set -u

if ! kubectl get configmap report-answers -n shipyard >/dev/null 2>&1; then
  echo "FAIL: ConfigMap report-answers not found in shipyard"
  exit 1
fi

expected_ns=""
for i in $(seq 1 24); do
  expected_ns=$(kubectl get clusterpolicyreport -o jsonpath='{range .items[*]}{.scope.kind}{" "}{.scope.name}{" "}{.summary.fail}{"\n"}{end}' 2>/dev/null \
    | awk '$1=="Namespace" && $3>0 {print $2}' | sort | paste -sd, -)
  if [[ -n "$expected_ns" ]]; then break; fi
  sleep 5
done

if [[ -z "$expected_ns" ]]; then
  echo "FAIL: the live ClusterPolicyReport shows no failing Namespace; the cluster is not ready"
  exit 1
fi

expected_mode=$(kubectl get clusterpolicy require-fleet-labels -o jsonpath='{.spec.rules[0].validate.failureAction}' 2>/dev/null)

got_ns=$(kubectl get configmap report-answers -n shipyard -o jsonpath='{.data.failing-namespace}' | tr -d ' ')
got_mode=$(kubectl get configmap report-answers -n shipyard -o jsonpath='{.data.policy-mode}' | tr -d ' ')

if [[ "$got_ns" != "$expected_ns" ]]; then
  echo "FAIL: failing-namespace is '$got_ns' but the live ClusterPolicyReport shows a different Namespace"
  exit 1
fi
if [[ "$got_mode" != "$expected_mode" ]]; then
  echo "FAIL: policy-mode is '$got_mode' but the policy uses a different failureAction"
  exit 1
fi

echo "PASS: failing Namespace and policy mode match the live cluster."
exit 0
