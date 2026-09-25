#!/usr/bin/env bash
# Confirms the kyverno Helm release upgraded to revision 2+, admission
# replicas is 3, and the cluster is still healthy after the upgrade.

set -u

history_lines=$(helm history kyverno -n kyverno 2>/dev/null | tail -n +2 | grep -c . || true)
if [[ -z "$history_lines" || "$history_lines" -lt 2 ]]; then
  echo "FAIL: helm history for release 'kyverno' shows fewer than 2 revisions"
  exit 1
fi

replicas=$(kubectl get deploy kyverno-admission-controller -n kyverno -o jsonpath='{.spec.replicas}' 2>/dev/null)
if [[ "$replicas" != "3" ]]; then
  echo "FAIL: kyverno-admission-controller replicas is '$replicas', expected 3"
  exit 1
fi

if ! kubectl get crd clusterpolicies.kyverno.io >/dev/null 2>&1; then
  echo "FAIL: clusterpolicies.kyverno.io CRD not found after upgrade"
  exit 1
fi

not_running=$(kubectl get pods -n kyverno --no-headers 2>/dev/null | grep -vc "Running" || true)
if [[ "$not_running" -gt 0 ]]; then
  echo "FAIL: $not_running pod(s) in the kyverno namespace are not Running"
  exit 1
fi

echo "PASS: kyverno release has $history_lines revisions, admission controller has 3 replicas, CRDs intact, and all pods are Running."
exit 0
