#!/usr/bin/env bash
# Confirms the Kyverno ConfigMap has generateSuccessEvents set to true.

set -u

value=$(kubectl get configmap kyverno -n kyverno -o jsonpath='{.data.generateSuccessEvents}' 2>/dev/null)
if [[ "$value" != "true" ]]; then
  echo "FAIL: generateSuccessEvents in the kyverno ConfigMap is '$value', expected 'true'"
  exit 1
fi

echo "PASS: generateSuccessEvents is true."
exit 0
