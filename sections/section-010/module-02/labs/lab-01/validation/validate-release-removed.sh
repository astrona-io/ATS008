#!/usr/bin/env bash
# The Helm release "kyverno" must be gone from every namespace, including
# releases stuck in a failed or uninstalling state (--all).

set -u

if ! releases=$(helm list -A --all -q 2>&1); then
  echo "FAIL: could not list Helm releases: $releases"
  exit 1
fi

if echo "$releases" | grep -qx 'kyverno'; then
  echo "FAIL: a Helm release named 'kyverno' still exists"
  exit 1
fi

echo "PASS: no Helm release named 'kyverno' exists."
exit 0
