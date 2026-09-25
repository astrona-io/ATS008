#!/usr/bin/env bash
# Confirms kyverno-generate-resourcequota exists with the right aggregation
# label, and that the ResourceQuota was generated in checkout-svc.

set -u

role_yaml=$(kubectl get clusterrole kyverno-generate-resourcequota -o yaml 2>/dev/null)
if [[ -z "$role_yaml" ]]; then
  echo "FAIL: ClusterRole kyverno-generate-resourcequota not found"
  exit 1
fi

if ! echo "$role_yaml" | grep -q "rbac.kyverno.io/aggregate-to-background-controller"; then
  echo "FAIL: kyverno-generate-resourcequota is missing the rbac.kyverno.io/aggregate-to-background-controller label"
  exit 1
fi

if ! echo "$role_yaml" | grep -q "resourcequotas"; then
  echo "FAIL: kyverno-generate-resourcequota does not grant permissions on resourcequotas"
  exit 1
fi

quota_pods=$(kubectl get resourcequota default-quota -n checkout-svc -o jsonpath='{.spec.hard.pods}' 2>/dev/null)
if [[ -z "$quota_pods" ]]; then
  echo "FAIL: default-quota ResourceQuota not found in checkout-svc"
  exit 1
fi

echo "PASS: kyverno-generate-resourcequota is correctly labeled and default-quota (pods=$quota_pods) generated in checkout-svc."
exit 0
