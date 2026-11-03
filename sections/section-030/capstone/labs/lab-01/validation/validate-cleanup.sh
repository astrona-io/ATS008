#!/usr/bin/env bash
# Confirms the cleanup controller runs with --ttlReconciliationInterval=5m.

set -u

cleanup_args=$(kubectl get deploy kyverno-cleanup-controller -n kyverno -o jsonpath='{.spec.template.spec.containers[0].args}' 2>/dev/null)
if [[ -z "$cleanup_args" ]]; then
  echo "FAIL: kyverno-cleanup-controller deployment not found"
  exit 1
fi

if ! echo "$cleanup_args" | grep -q -- '"--ttlReconciliationInterval=5m"'; then
  echo "FAIL: kyverno-cleanup-controller args missing --ttlReconciliationInterval=5m (got: $cleanup_args)"
  exit 1
fi

echo "PASS: cleanup controller has ttlReconciliationInterval=5m."
exit 0
