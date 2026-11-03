#!/usr/bin/env bash
# No custom resource definition whose name ends in kyverno.io. The policy
# report definitions under wgpolicyk8s.io are not checked.

set -u

if ! out=$(kubectl get crd -o name 2>&1); then
  echo "FAIL: could not list custom resource definitions: $out"
  exit 1
fi

left=$(echo "$out" | grep -E 'kyverno\.io$' || true)
if [[ -n "$left" ]]; then
  echo "FAIL: custom resource definitions ending in kyverno.io remain:"
  echo "$left"
  exit 1
fi

echo "PASS: no custom resource definition ending in kyverno.io remains."
exit 0
