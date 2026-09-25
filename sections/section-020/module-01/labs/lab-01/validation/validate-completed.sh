#!/usr/bin/env bash
# Confirms PolicyException is enabled, except-checkout-smoke-test exists, smoke-test
# was admitted, and no-owner-pod was still blocked.

set -u

if ! kubectl get deploy kyverno-admission-controller -n kyverno -o yaml 2>/dev/null | grep -q -- '--enablePolicyException=true'; then
  echo "FAIL: kyverno-admission-controller does not have --enablePolicyException=true"
  exit 1
fi

if ! kubectl get policyexception except-checkout-smoke-test -n checkout >/dev/null 2>&1; then
  echo "FAIL: except-checkout-smoke-test PolicyException not found in checkout"
  exit 1
fi

if ! kubectl get pod smoke-test -n checkout >/dev/null 2>&1; then
  echo "FAIL: smoke-test Pod not found in checkout - it should have been admitted via the exception"
  exit 1
fi

if kubectl get pod no-owner-pod -n checkout >/dev/null 2>&1; then
  echo "FAIL: no-owner-pod exists in checkout - it should have been blocked by require-owner-label"
  exit 1
fi

echo "PASS: PolicyException enabled, except-checkout-smoke-test admits smoke-test, and no-owner-pod remains blocked."
exit 0
