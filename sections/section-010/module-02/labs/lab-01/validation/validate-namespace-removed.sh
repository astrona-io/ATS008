#!/usr/bin/env bash
# The kyverno namespace must be gone, not just Terminating. Waits up to 90
# seconds, because a namespace can take a while to finish deleting.

set -u

for i in $(seq 1 18); do
  if ! out=$(kubectl get namespaces -o name 2>&1); then
    echo "FAIL: could not list namespaces: $out"
    exit 1
  fi
  if ! echo "$out" | grep -qx 'namespace/kyverno'; then
    echo "PASS: the kyverno namespace is gone."
    exit 0
  fi
  sleep 5
done

echo "FAIL: the kyverno namespace still exists (it may be Terminating)"
exit 1
