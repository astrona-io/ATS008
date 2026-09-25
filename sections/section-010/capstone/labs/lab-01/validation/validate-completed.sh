#!/usr/bin/env bash
# Confirms the values-file install: admissionController.replicas=2,
# cleanupController disabled, and config.excludeGroups extended without
# losing its built-in defaults.

set -u

replicas=$(kubectl get deploy kyverno-admission-controller -n kyverno -o jsonpath='{.spec.replicas}' 2>/dev/null)
if [[ "$replicas" != "2" ]]; then
  echo "FAIL: kyverno-admission-controller replicas is '$replicas', expected 2"
  exit 1
fi

cleanup_replicas=$(kubectl get deploy kyverno-cleanup-controller -n kyverno -o jsonpath='{.spec.replicas}' 2>/dev/null)
if kubectl get deploy kyverno-cleanup-controller -n kyverno >/dev/null 2>&1; then
  if [[ "$cleanup_replicas" != "0" ]]; then
    echo "FAIL: kyverno-cleanup-controller exists with replicas='$cleanup_replicas', expected it disabled (absent or 0 replicas)"
    exit 1
  fi
fi

cm_dump=$(kubectl get cm -n kyverno -o yaml 2>/dev/null)
if ! echo "$cm_dump" | grep -q "system:serviceaccounts:ci"; then
  echo "FAIL: config.excludeGroups does not contain system:serviceaccounts:ci"
  exit 1
fi
if ! echo "$cm_dump" | grep -q "system:serviceaccounts:kube-system"; then
  echo "FAIL: config.excludeGroups lost the built-in default system:serviceaccounts:kube-system"
  exit 1
fi
if ! echo "$cm_dump" | grep -q "system:nodes"; then
  echo "FAIL: config.excludeGroups lost the built-in default system:nodes"
  exit 1
fi

echo "PASS: admissionController.replicas=2, cleanup controller disabled, and excludeGroups extended without dropping the defaults."
exit 0
