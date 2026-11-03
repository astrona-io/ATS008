#!/usr/bin/env bash
# Confirms the Kyverno ConfigMap excludes the service account
# system:serviceaccount:mission-ops:flight-bot and still excludes system:nodes.

set -u

users=$(kubectl get configmap kyverno -n kyverno -o jsonpath='{.data.excludeUsernames}' 2>/dev/null)
if ! echo "$users" | grep -qF "system:serviceaccount:mission-ops:flight-bot"; then
  echo "FAIL: excludeUsernames in the kyverno ConfigMap does not contain system:serviceaccount:mission-ops:flight-bot (got: '$users')"
  exit 1
fi

groups=$(kubectl get configmap kyverno -n kyverno -o jsonpath='{.data.excludeGroups}' 2>/dev/null)
if ! echo "$groups" | grep -qF "system:nodes"; then
  echo "FAIL: excludeGroups no longer contains system:nodes (got: '$groups')"
  exit 1
fi

echo "PASS: flight-bot is excluded and system:nodes is still excluded."
exit 0
