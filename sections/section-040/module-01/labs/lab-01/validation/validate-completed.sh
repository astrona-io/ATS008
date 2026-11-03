#!/usr/bin/env bash
# Checks, in order: the ClusterRole exists with the aggregation label and a
# resourcequotas rule; the chart's own background :core role was not given a
# resourcequotas rule; the background controller can create resourcequotas;
# default-quota exists in checkout-svc (polled for up to 60 seconds).

set -u

role_label=$(kubectl get clusterrole kyverno-generate-resourcequota -o jsonpath='{.metadata.labels.rbac\.kyverno\.io/aggregate-to-background-controller}' 2>/dev/null)
if [[ "$role_label" != "true" ]]; then
  echo "FAIL: ClusterRole kyverno-generate-resourcequota is missing or lacks the label rbac.kyverno.io/aggregate-to-background-controller: \"true\""
  exit 1
fi

role_rules=$(kubectl get clusterrole kyverno-generate-resourcequota -o jsonpath='{range .rules[*]}{.apiGroups}{" "}{.resources}{" "}{.verbs}{"\n"}{end}' 2>/dev/null)
if ! echo "$role_rules" | grep "resourcequotas" | grep -q "create"; then
  echo "FAIL: kyverno-generate-resourcequota does not allow create on resourcequotas"
  exit 1
fi

core_rules=$(kubectl get clusterrole kyverno:background-controller:core -o jsonpath='{range .rules[*]}{.resources}{" "}{.verbs}{"\n"}{end}' 2>/dev/null)
if echo "$core_rules" | grep "resourcequotas" | grep -q "create"; then
  echo "FAIL: kyverno:background-controller:core was changed to allow resourcequotas; add a new ClusterRole instead"
  exit 1
fi

answer=$(kubectl auth can-i create resourcequotas --as=system:serviceaccount:kyverno:kyverno-background-controller 2>/dev/null)
if [[ "$answer" != "yes" ]]; then
  echo "FAIL: the background controller still cannot create resourcequotas"
  exit 1
fi

quota_pods=""
for i in $(seq 1 30); do
  quota_pods=$(kubectl get resourcequota default-quota -n checkout-svc -o jsonpath='{.spec.hard.pods}' 2>/dev/null)
  if [[ -n "$quota_pods" ]]; then
    break
  fi
  sleep 2
done
if [[ -z "$quota_pods" ]]; then
  echo "FAIL: default-quota ResourceQuota not found in checkout-svc"
  exit 1
fi

echo "PASS: kyverno-generate-resourcequota is labelled, the permission is live and default-quota (pods=$quota_pods) was generated in checkout-svc."
exit 0
