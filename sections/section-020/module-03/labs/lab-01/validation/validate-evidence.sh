#!/usr/bin/env bash
# The lab is read-only. Confirms that the policies are still Audit and that the
# four Deployments still lack the labels they lacked at the start.

set -u

for rule in 0 1; do
  mode=$(kubectl get clusterpolicy require-fleet-labels -o jsonpath="{.spec.rules[$rule].validate.failureAction}" 2>/dev/null)
  if [[ "$mode" != "Audit" ]]; then
    echo "FAIL: rule $rule of require-fleet-labels is '$mode', expected Audit"
    exit 1
  fi
done

mode=$(kubectl get clusterpolicy require-yard-env -o jsonpath='{.spec.rules[0].validate.failureAction}' 2>/dev/null)
if [[ "$mode" != "Audit" ]]; then
  echo "FAIL: require-yard-env is '$mode', expected Audit"
  exit 1
fi

for d in scout probe relay shuttle; do
  if ! kubectl get deployment "$d" -n shipyard >/dev/null 2>&1; then
    echo "FAIL: deployment $d is missing from shipyard"
    exit 1
  fi
done

if [[ -n "$(kubectl get deployment probe -n shipyard -o jsonpath='{.metadata.labels.owner}')" ]] \
  || [[ -n "$(kubectl get deployment relay -n shipyard -o jsonpath='{.metadata.labels.owner}{.metadata.labels.team}')" ]] \
  || [[ -n "$(kubectl get deployment shuttle -n shipyard -o jsonpath='{.metadata.labels.team}')" ]]; then
  echo "FAIL: the violating Deployments were changed. This lab only reads the reports."
  exit 1
fi

echo "PASS: policies and Deployments are untouched."
exit 0
