#!/usr/bin/env bash
# Confirms the changes came through Helm: the manifest stored in the release
# holds the same three settings, and the release has more than one revision.

set -u

manifest=$(helm get manifest kyverno -n kyverno 2>/dev/null)
if [[ -z "$manifest" ]]; then
  echo "FAIL: the Helm release kyverno was not found in the kyverno namespace"
  exit 1
fi

for text in "system:serviceaccount:mission-ops:flight-bot" 'generateSuccessEvents: "true"' "[*/*,mission-ops,*]"; do
  if ! echo "$manifest" | grep -qF "$text"; then
    echo "FAIL: the Helm release does not hold '$text'. Make the change with helm upgrade, not with kubectl edit."
    exit 1
  fi
done

revision=$(helm list -n kyverno -f '^kyverno$' -o json 2>/dev/null | grep -o '"revision":"[0-9]*"' | grep -o '[0-9]*')
if [[ -z "$revision" || "$revision" -lt 2 ]]; then
  echo "FAIL: the release is still at revision '${revision:-?}'; run helm upgrade"
  exit 1
fi

echo "PASS: the release holds all three settings (revision $revision)."
exit 0
