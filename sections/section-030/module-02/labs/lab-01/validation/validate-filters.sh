#!/usr/bin/env bash
# Confirms the resource filters skip mission-ops and still hold the default
# entries.

set -u

filters=$(kubectl get configmap kyverno -n kyverno -o jsonpath='{.data.resourceFilters}' 2>/dev/null)

if ! echo "$filters" | grep -qF "[*/*,mission-ops,*]"; then
  echo "FAIL: resourceFilters does not contain [*/*,mission-ops,*]"
  exit 1
fi

for entry in "[Event,*,*]" "[Node,*,*]" "[*/*,kube-system,*]" "[*/*,kube-public,*]"; do
  if ! echo "$filters" | grep -qF "$entry"; then
    echo "FAIL: the default filter $entry is missing. Add to the filters with the helper lists; do not replace the whole list."
    exit 1
  fi
done

echo "PASS: mission-ops is skipped and the default filters are still there."
exit 0
