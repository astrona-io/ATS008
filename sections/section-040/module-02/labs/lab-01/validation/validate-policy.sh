#!/usr/bin/env bash
# The ClusterCleanupPolicy purge-expired-notes exists and targets ConfigMaps in
# scrap with the label expired=true on a schedule.
set -u

if ! kubectl get clustercleanuppolicy purge-expired-notes >/dev/null 2>&1; then
  echo "FAIL: ClusterCleanupPolicy purge-expired-notes not found"
  exit 1
fi

schedule=$(kubectl get clustercleanuppolicy purge-expired-notes -o jsonpath='{.spec.schedule}' 2>/dev/null)
if [[ -z "$schedule" ]]; then
  echo "FAIL: purge-expired-notes has no schedule"
  exit 1
fi

spec=$(kubectl get clustercleanuppolicy purge-expired-notes -o jsonpath='{.spec.match}' 2>/dev/null)
for needle in ConfigMap scrap expired; do
  if ! echo "$spec" | grep -q "$needle"; then
    echo "FAIL: spec.match of purge-expired-notes does not mention $needle"
    exit 1
  fi
done

echo "PASS: purge-expired-notes exists (schedule '$schedule') and matches expired ConfigMaps in scrap."
exit 0
