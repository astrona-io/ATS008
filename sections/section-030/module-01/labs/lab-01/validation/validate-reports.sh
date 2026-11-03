#!/usr/bin/env bash
# Confirms the reports controller runs with --backgroundScanInterval=30m.

set -u

reports_args=$(kubectl get deploy kyverno-reports-controller -n kyverno -o jsonpath='{.spec.template.spec.containers[0].args}' 2>/dev/null)
if [[ -z "$reports_args" ]]; then
  echo "FAIL: kyverno-reports-controller deployment not found"
  exit 1
fi

if ! echo "$reports_args" | grep -q -- '"--backgroundScanInterval=30m"'; then
  echo "FAIL: kyverno-reports-controller args do not contain --backgroundScanInterval=30m (got: $reports_args)"
  exit 1
fi

echo "PASS: reports controller has --backgroundScanInterval=30m."
exit 0
