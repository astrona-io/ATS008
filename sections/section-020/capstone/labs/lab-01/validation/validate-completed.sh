#!/usr/bin/env bash
# Confirms both PolicyExceptions exist, their probe resources were admitted, and
# the control Pod for require-owner-label was still blocked.

set -u

if ! kubectl get policyexception except-checkout-batch-jobs -n checkout >/dev/null 2>&1; then
  echo "FAIL: except-checkout-batch-jobs PolicyException not found"
  exit 1
fi

if ! kubectl get policyexception except-checkout-nightly-batch -n checkout >/dev/null 2>&1; then
  echo "FAIL: except-checkout-nightly-batch PolicyException not found"
  exit 1
fi

if ! kubectl get pod batch-worker -n checkout >/dev/null 2>&1; then
  echo "FAIL: batch-worker Pod not found - it should have been admitted via except-checkout-batch-jobs"
  exit 1
fi

if kubectl get pod unlabeled-worker -n checkout >/dev/null 2>&1; then
  echo "FAIL: unlabeled-worker exists in checkout - it should have been blocked by require-owner-label"
  exit 1
fi

if ! kubectl get deployment nightly-batch -n checkout >/dev/null 2>&1; then
  echo "FAIL: nightly-batch Deployment not found - it should have been admitted via except-checkout-nightly-batch"
  exit 1
fi

echo "PASS: both PolicyExceptions admit their targets, and unlabeled-worker remains blocked."
exit 0
