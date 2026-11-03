#!/usr/bin/env bash
# Confirms the cleanup controller service account may delete ConfigMaps in
# salvage-yard.

set -u

answer=$(kubectl auth can-i delete configmaps -n salvage-yard --as=system:serviceaccount:kyverno:kyverno-cleanup-controller 2>/dev/null)
if [[ "$answer" != "yes" ]]; then
  echo "FAIL: the cleanup controller may not delete configmaps in salvage-yard (can-i says '$answer')"
  exit 1
fi

echo "PASS: the cleanup controller may delete configmaps."
exit 0
