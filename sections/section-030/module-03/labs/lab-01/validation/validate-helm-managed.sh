#!/usr/bin/env bash
# The settings must come from Helm (revision 2 or higher, forceFailurePolicyIgnore
# and the mission-ops selector in the release), and the admission controller must
# be running.

set -u

manifest=$(helm get manifest kyverno -n kyverno 2>/dev/null)
if [[ -z "$manifest" ]]; then
  echo "FAIL: the Helm release kyverno was not found in the kyverno namespace"
  exit 1
fi
if ! echo "$manifest" | grep -q "forceFailurePolicyIgnore=true"; then
  echo "FAIL: the Helm release does not hold --forceFailurePolicyIgnore=true. Use helm upgrade, not kubectl edit."
  exit 1
fi
if ! echo "$manifest" | grep -q "mission-ops"; then
  echo "FAIL: the Helm release does not hold the mission-ops webhook selector. Use helm upgrade, not kubectl edit."
  exit 1
fi

revision=$(helm list -n kyverno -f '^kyverno$' -o json 2>/dev/null | grep -o '"revision":"[0-9]*"' | grep -o '[0-9]*')
if [[ -z "$revision" || "$revision" -lt 2 ]]; then
  echo "FAIL: the release is still at revision '${revision:-?}'; run helm upgrade"
  exit 1
fi

ready=$(kubectl get deployment kyverno-admission-controller -n kyverno -o jsonpath='{.status.readyReplicas}' 2>/dev/null)
if [[ -z "$ready" || "$ready" -lt 1 ]]; then
  echo "FAIL: the admission controller has no ready Pod"
  exit 1
fi

echo "PASS: the release holds the settings (revision $revision) and the admission controller is ready."
exit 0
