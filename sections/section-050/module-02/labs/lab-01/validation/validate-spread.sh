#!/usr/bin/env bash
# Status: UNTESTED (written statically, not yet run against a cluster).
# The admission Deployment carries the topology spread constraint and the
# priority class.
set -u

P='{.spec.template.spec.topologySpreadConstraints[0]'
get() { kubectl get deploy kyverno-admission-controller -n kyverno -o jsonpath="$1" 2>/dev/null; }

expect() {
  local what="$1" actual="$2" expected="$3"
  if [[ "$actual" != "$expected" ]]; then
    echo "FAIL: admission Deployment $what is '$actual', expected '$expected'"
    exit 1
  fi
}

count=$(kubectl get deploy kyverno-admission-controller -n kyverno -o jsonpath='{.spec.template.spec.topologySpreadConstraints[*].topologyKey}' 2>/dev/null | wc -w | tr -d ' ')
if [[ "$count" -lt 1 ]]; then
  echo "FAIL: admission Deployment has no topologySpreadConstraints"
  exit 1
fi

expect "maxSkew" "$(get "${P}.maxSkew}")" "1"
expect "topologyKey" "$(get "${P}.topologyKey}")" "kubernetes.io/hostname"
expect "whenUnsatisfiable" "$(get "${P}.whenUnsatisfiable}")" "ScheduleAnyway"
expect "labelSelector component" "$(get "${P}.labelSelector.matchLabels.app\.kubernetes\.io/component}")" "admission-controller"
expect "priorityClassName" "$(get '{.spec.template.spec.priorityClassName}')" "system-cluster-critical"

echo "PASS: admission spread constraint and priority class are set."
exit 0
