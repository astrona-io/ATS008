#!/usr/bin/env bash
# Status: UNTESTED (written statically, not yet run against a cluster).
# The policy is not part of the Helm release, so a rollback keeps it. An
# unlabeled Pod in finance must still be refused by the admission controller.
# Polls for up to 90 seconds because the webhook needs a healthy controller.
set -u

if ! kubectl get clusterpolicy require-cost-center-label >/dev/null 2>&1; then
  echo "FAIL: ClusterPolicy require-cost-center-label no longer exists"
  exit 1
fi

for i in $(seq 1 18); do
  out=$(kubectl -n finance run grader-unlabeled --image=busybox --dry-run=server 2>&1)
  rc=$?
  if [[ $rc -ne 0 && "$out" == *"cost-center"* ]]; then
    echo "PASS: require-cost-center-label exists and refuses an unlabeled Pod in finance."
    exit 0
  fi
  sleep 5
done

echo "FAIL: an unlabeled Pod in finance was not refused by the policy"
exit 1
