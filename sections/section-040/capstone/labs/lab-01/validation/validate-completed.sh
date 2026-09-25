#!/usr/bin/env bash
# Confirms kyverno-generate-networkpolicy exists with the right aggregation
# label, and that the NetworkPolicy was generated in billing-svc.

set -u

role_yaml=$(kubectl get clusterrole kyverno-generate-networkpolicy -o yaml 2>/dev/null)
if [[ -z "$role_yaml" ]]; then
  echo "FAIL: ClusterRole kyverno-generate-networkpolicy not found"
  exit 1
fi

if ! echo "$role_yaml" | grep -q "rbac.kyverno.io/aggregate-to-background-controller"; then
  echo "FAIL: kyverno-generate-networkpolicy is missing the rbac.kyverno.io/aggregate-to-background-controller label"
  exit 1
fi

if ! echo "$role_yaml" | grep -q "networkpolicies"; then
  echo "FAIL: kyverno-generate-networkpolicy does not grant permissions on networkpolicies"
  exit 1
fi

np_json=$(kubectl get networkpolicy default-deny -n billing-svc -o json 2>/dev/null)
if [[ -z "$np_json" ]]; then
  echo "FAIL: default-deny NetworkPolicy not found in billing-svc"
  exit 1
fi

echo "PASS: kyverno-generate-networkpolicy is correctly labeled and default-deny generated in billing-svc."
exit 0
