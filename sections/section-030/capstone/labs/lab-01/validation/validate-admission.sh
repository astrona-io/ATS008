#!/usr/bin/env bash
# Confirms the admission controller runs with --webhookTimeout=15,
# --enablePolicyException=true and --exceptionNamespace=capstone-030.

set -u

admission_args=$(kubectl get deploy kyverno-admission-controller -n kyverno -o jsonpath='{.spec.template.spec.containers[0].args}' 2>/dev/null)
if [[ -z "$admission_args" ]]; then
  echo "FAIL: kyverno-admission-controller deployment not found"
  exit 1
fi

for flag in "--webhookTimeout=15" "--enablePolicyException=true" "--exceptionNamespace=capstone-030"; do
  if ! echo "$admission_args" | grep -q -- "\"$flag\""; then
    echo "FAIL: kyverno-admission-controller args missing $flag (got: $admission_args)"
    exit 1
  fi
done

echo "PASS: admission controller has webhookTimeout, enablePolicyException and exceptionNamespace set."
exit 0
