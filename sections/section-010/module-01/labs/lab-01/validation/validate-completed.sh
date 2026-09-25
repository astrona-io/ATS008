#!/usr/bin/env bash
# Confirms Kyverno was installed via Helm as release "kyverno" in namespace
# "kyverno", with admissionController.replicas=2 and the required resource
# requests on the admission controller container.

set -u

helm_list=$(helm list -n kyverno 2>/dev/null)
if ! echo "$helm_list" | grep -qE '^kyverno[[:space:]]'; then
  echo "FAIL: no Helm release named 'kyverno' found in namespace kyverno"
  exit 1
fi

helm_status=$(helm status kyverno -n kyverno 2>/dev/null)
if ! echo "$helm_status" | grep -q "STATUS: deployed"; then
  echo "FAIL: kyverno release status is not 'deployed'"
  exit 1
fi

replicas=$(kubectl get deploy kyverno-admission-controller -n kyverno -o jsonpath='{.spec.replicas}' 2>/dev/null)
if [[ "$replicas" != "2" ]]; then
  echo "FAIL: kyverno-admission-controller replicas is '$replicas', expected 2"
  exit 1
fi

cpu_req=$(kubectl get deploy kyverno-admission-controller -n kyverno -o jsonpath='{.spec.template.spec.containers[0].resources.requests.cpu}' 2>/dev/null)
if [[ "$cpu_req" != "100m" ]]; then
  echo "FAIL: admission controller cpu request is '$cpu_req', expected 100m"
  exit 1
fi

mem_req=$(kubectl get deploy kyverno-admission-controller -n kyverno -o jsonpath='{.spec.template.spec.containers[0].resources.requests.memory}' 2>/dev/null)
if [[ "$mem_req" != "128Mi" ]]; then
  echo "FAIL: admission controller memory request is '$mem_req', expected 128Mi"
  exit 1
fi

if ! kubectl get crd clusterpolicies.kyverno.io >/dev/null 2>&1; then
  echo "FAIL: clusterpolicies.kyverno.io CRD not found - CRDs were not installed"
  exit 1
fi

echo "PASS: kyverno release deployed with admissionController.replicas=2, resource requests cpu=100m/memory=128Mi, and CRDs installed."
exit 0
