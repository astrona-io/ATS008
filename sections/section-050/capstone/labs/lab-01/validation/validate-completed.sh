#!/usr/bin/env bash
# Confirms HA replica counts across all four controllers AND that the
# admission controller's resource requests were set correctly.

set -u

check_replicas() {
  local deploy="$1"
  local expected="$2"
  local actual
  actual=$(kubectl get deploy "$deploy" -n kyverno -o jsonpath='{.spec.replicas}' 2>/dev/null)
  if [[ "$actual" != "$expected" ]]; then
    echo "FAIL: $deploy - expected $expected replicas, got '$actual'"
    exit 1
  fi
}

check_replicas "kyverno-admission-controller" "3"
check_replicas "kyverno-background-controller" "2"
check_replicas "kyverno-reports-controller" "2"
check_replicas "kyverno-cleanup-controller" "2"

cpu=$(kubectl get deploy kyverno-admission-controller -n kyverno -o jsonpath='{.spec.template.spec.containers[0].resources.requests.cpu}' 2>/dev/null)
mem=$(kubectl get deploy kyverno-admission-controller -n kyverno -o jsonpath='{.spec.template.spec.containers[0].resources.requests.memory}' 2>/dev/null)

if [[ "$cpu" != "200m" ]]; then
  echo "FAIL: admission controller resources.requests.cpu is '$cpu', expected 200m"
  exit 1
fi

if [[ "$mem" != "256Mi" ]]; then
  echo "FAIL: admission controller resources.requests.memory is '$mem', expected 256Mi"
  exit 1
fi

echo "PASS: HA replica counts (3/2/2/2) confirmed, admission controller requests cpu=$cpu memory=$mem."
exit 0
