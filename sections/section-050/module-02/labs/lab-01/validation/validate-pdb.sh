#!/usr/bin/env bash
# Status: UNTESTED (written statically, not yet run against a cluster).
# The admission PodDisruptionBudget has maxUnavailable 1, no minAvailable and
# allows 1 disruption; the background budget keeps minAvailable 1.
set -u

max=$(kubectl get pdb kyverno-admission-controller -n kyverno -o jsonpath='{.spec.maxUnavailable}' 2>/dev/null)
min=$(kubectl get pdb kyverno-admission-controller -n kyverno -o jsonpath='{.spec.minAvailable}' 2>/dev/null)
if [[ "$max" != "1" ]]; then
  echo "FAIL: PodDisruptionBudget kyverno-admission-controller maxUnavailable is '$max', expected 1"
  exit 1
fi
if [[ -n "$min" ]]; then
  echo "FAIL: PodDisruptionBudget kyverno-admission-controller still sets minAvailable '$min'; clear it"
  exit 1
fi

allowed=""
for i in $(seq 1 40); do
  allowed=$(kubectl get pdb kyverno-admission-controller -n kyverno -o jsonpath='{.status.disruptionsAllowed}' 2>/dev/null)
  [[ "$allowed" == "1" ]] && break
  sleep 3
done
if [[ "$allowed" != "1" ]]; then
  echo "FAIL: admission budget allows '$allowed' disruptions, expected 1 (are all 3 Pods ready?)"
  exit 1
fi

bg_min=$(kubectl get pdb kyverno-background-controller -n kyverno -o jsonpath='{.spec.minAvailable}' 2>/dev/null)
if [[ "$bg_min" != "1" ]]; then
  echo "FAIL: PodDisruptionBudget kyverno-background-controller minAvailable is '$bg_min', expected the default 1"
  exit 1
fi

echo "PASS: admission budget maxUnavailable=1 allows 1 disruption; background budget minAvailable=1."
exit 0
