#!/usr/bin/env bash
# Live effect: the two expired ConfigMaps are deleted and keep-note stays.
# Polls for up to 180 seconds because the cleanup runs on a schedule.
set -u

gone=0
for i in $(seq 1 36); do
  if ! kubectl get configmap old-note-1 -n scrap >/dev/null 2>&1 \
     && ! kubectl get configmap old-note-2 -n scrap >/dev/null 2>&1; then
    gone=1
    break
  fi
  sleep 5
done
if [[ "$gone" != "1" ]]; then
  echo "FAIL: old-note-1 or old-note-2 still exists in scrap after 180 seconds"
  exit 1
fi

if ! kubectl get configmap keep-note -n scrap >/dev/null 2>&1; then
  echo "FAIL: keep-note was deleted; the policy must only match expired: \"true\""
  exit 1
fi

echo "PASS: the expired ConfigMaps are gone and keep-note is still in scrap."
exit 0
