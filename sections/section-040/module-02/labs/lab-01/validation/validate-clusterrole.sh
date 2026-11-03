#!/usr/bin/env bash
# A ClusterRole with the cleanup aggregation label exists and allows delete on
# configmaps; the shipped kyverno:cleanup-controller:core role has no rule that
# lets it delete configmaps.
set -u

found=""
for name in $(kubectl get clusterrole -l rbac.kyverno.io/aggregate-to-cleanup-controller=true -o name 2>/dev/null); do
  rules=$(kubectl get "$name" -o jsonpath='{range .rules[*]}{.resources}{" "}{.verbs}{"\n"}{end}' 2>/dev/null)
  if echo "$rules" | grep "configmaps" | grep -q "delete"; then
    found="$name"
  fi
done
if [[ -z "$found" ]]; then
  echo "FAIL: no ClusterRole with the label rbac.kyverno.io/aggregate-to-cleanup-controller=true allows delete on configmaps"
  exit 1
fi

core_rules=$(kubectl get clusterrole kyverno:cleanup-controller:core -o jsonpath='{range .rules[*]}{.resources}{" "}{.verbs}{"\n"}{end}' 2>/dev/null)
if echo "$core_rules" | grep "configmaps" | grep -q "delete"; then
  echo "FAIL: kyverno:cleanup-controller:core was changed; add a new ClusterRole instead"
  exit 1
fi

echo "PASS: $found carries the cleanup label and allows delete on configmaps; the shipped core role is untouched."
exit 0
