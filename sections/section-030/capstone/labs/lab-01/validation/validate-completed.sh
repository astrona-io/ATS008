#!/usr/bin/env bash
# Confirms the admission controller runs with --webhookTimeout=15,
# --enablePolicyException=true, --exceptionNamespace=capstone-030, and the
# cleanup controller runs with --ttlReconciliationInterval=5m.

set -u

admission_args=$(kubectl get deploy kyverno-admission-controller -n kyverno -o jsonpath='{.spec.template.spec.containers[0].args}' 2>/dev/null)
if [[ -z "$admission_args" ]]; then
  echo "FAIL: kyverno-admission-controller deployment not found"
  exit 1
fi

for flag in "--webhookTimeout=15" "--enablePolicyException=true" "--exceptionNamespace=capstone-030"; do
  if ! echo "$admission_args" | grep -q -- "$flag"; then
    echo "FAIL: kyverno-admission-controller args missing $flag (got: $admission_args)"
    exit 1
  fi
done

cleanup_args=$(kubectl get deploy kyverno-cleanup-controller -n kyverno -o jsonpath='{.spec.template.spec.containers[0].args}' 2>/dev/null)
if [[ -z "$cleanup_args" ]]; then
  echo "FAIL: kyverno-cleanup-controller deployment not found"
  exit 1
fi

if ! echo "$cleanup_args" | grep -q -- "--ttlReconciliationInterval=5m"; then
  echo "FAIL: kyverno-cleanup-controller args missing --ttlReconciliationInterval=5m (got: $cleanup_args)"
  exit 1
fi

echo "PASS: admission controller has webhookTimeout/enablePolicyException/exceptionNamespace set, cleanup controller has ttlReconciliationInterval=5m."
exit 0
