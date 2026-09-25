#!/usr/bin/env bash
# Confirms Kyverno is installed with the documented HA replica counts
# (admission=3, background=2, reports=2, cleanup=2) and that at least one
# Lease object exists in the kyverno namespace, proving leader election is
# active.

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

lease_count=$(kubectl get lease -n kyverno --no-headers 2>/dev/null | wc -l | tr -d ' ')
if [[ -z "$lease_count" || "$lease_count" -lt 1 ]]; then
  echo "FAIL: no Lease objects found in the kyverno namespace - leader election does not appear active"
  exit 1
fi

echo "PASS: admission=3, background=2, reports=2, cleanup=2 replicas confirmed, and $lease_count Lease object(s) found."
exit 0
