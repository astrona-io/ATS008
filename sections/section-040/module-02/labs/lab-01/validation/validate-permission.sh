#!/usr/bin/env bash
# Live permission check as the cleanup controller's service account.
set -u

SA="system:serviceaccount:kyverno:kyverno-cleanup-controller"

answer=$(kubectl auth can-i delete configmaps -n scrap --as="$SA" 2>/dev/null)
if [[ "$answer" != "yes" ]]; then
  echo "FAIL: the cleanup controller cannot delete configmaps in scrap"
  exit 1
fi

for kind in secrets pods; do
  answer=$(kubectl auth can-i delete "$kind" -n scrap --as="$SA" 2>/dev/null)
  if [[ "$answer" != "no" ]]; then
    echo "FAIL: the cleanup controller may delete $kind in scrap; grant only configmaps"
    exit 1
  fi
done

echo "PASS: the cleanup controller may delete configmaps in scrap and nothing wider."
exit 0
