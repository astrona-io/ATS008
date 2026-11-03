#!/usr/bin/env bash
# Confirms the CleanupPolicy remove-scrap exists in salvage-yard, matches
# ConfigMaps and uses the every-minute schedule.

set -u

if ! kubectl get cleanuppolicies.kyverno.io remove-scrap -n salvage-yard >/dev/null 2>&1; then
  echo "FAIL: CleanupPolicy remove-scrap not found in salvage-yard"
  exit 1
fi

schedule=$(kubectl get cleanuppolicies.kyverno.io remove-scrap -n salvage-yard -o jsonpath='{.spec.schedule}' 2>/dev/null)
if [[ "$schedule" != "* * * * *" ]]; then
  echo "FAIL: remove-scrap has schedule '$schedule' but it must be '* * * * *'"
  exit 1
fi

if ! kubectl get cleanuppolicies.kyverno.io remove-scrap -n salvage-yard -o yaml 2>/dev/null | grep -q "ConfigMap"; then
  echo "FAIL: remove-scrap does not match the kind ConfigMap"
  exit 1
fi

echo "PASS: CleanupPolicy remove-scrap matches ConfigMaps with the schedule '* * * * *'."
exit 0
