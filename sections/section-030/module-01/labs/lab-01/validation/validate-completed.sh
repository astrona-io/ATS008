#!/usr/bin/env bash
# Confirms the background controller runs with --genWorkers=5 and the reports
# controller runs with --backgroundScanInterval=30m.

set -u

bg_args=$(kubectl get deploy kyverno-background-controller -n kyverno -o jsonpath='{.spec.template.spec.containers[0].args}' 2>/dev/null)
if [[ -z "$bg_args" ]]; then
  echo "FAIL: kyverno-background-controller deployment not found"
  exit 1
fi

if ! echo "$bg_args" | grep -q -- "--genWorkers=5"; then
  echo "FAIL: kyverno-background-controller args do not contain --genWorkers=5 (got: $bg_args)"
  exit 1
fi

reports_args=$(kubectl get deploy kyverno-reports-controller -n kyverno -o jsonpath='{.spec.template.spec.containers[0].args}' 2>/dev/null)
if [[ -z "$reports_args" ]]; then
  echo "FAIL: kyverno-reports-controller deployment not found"
  exit 1
fi

if ! echo "$reports_args" | grep -q -- "--backgroundScanInterval=30m"; then
  echo "FAIL: kyverno-reports-controller args do not contain --backgroundScanInterval=30m (got: $reports_args)"
  exit 1
fi

echo "PASS: background controller has --genWorkers=5 and reports controller has --backgroundScanInterval=30m."
exit 0
