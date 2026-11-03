#!/usr/bin/env bash
# forceFailurePolicyIgnore must be on, and no live Kyverno resource webhook may
# still carry failurePolicy Fail.

set -u

args=$(kubectl get deployment kyverno-admission-controller -n kyverno \
  -o jsonpath='{.spec.template.spec.containers[*].args}' 2>/dev/null)
if ! echo "$args" | grep -q "forceFailurePolicyIgnore=true"; then
  echo "FAIL: the admission controller does not run with --forceFailurePolicyIgnore=true"
  exit 1
fi

ok=0
for _ in $(seq 1 30); do
  policies=$(kubectl get validatingwebhookconfiguration kyverno-resource-validating-webhook-cfg \
    -o jsonpath='{.webhooks[*].failurePolicy}' 2>/dev/null)
  if [[ -n "$policies" ]] && ! echo "$policies" | grep -q "Fail"; then
    ok=1
    break
  fi
  sleep 3
done
if [[ "$ok" != 1 ]]; then
  echo "FAIL: the live validating webhook configuration still holds failurePolicy Fail (found: ${policies:-none})"
  exit 1
fi

echo "PASS: every live resource webhook has failurePolicy Ignore."
exit 0
