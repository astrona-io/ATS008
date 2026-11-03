#!/usr/bin/env bash
# The Kyverno ConfigMap must skip mission-ops in its webhook namespaceSelector,
# keep kube-system, and the live resource webhook must show the same change.

set -u

hooks=$(kubectl get configmap kyverno -n kyverno -o jsonpath='{.data.webhooks}' 2>/dev/null)
if [[ -z "$hooks" ]]; then
  echo "FAIL: the kyverno ConfigMap has no webhooks key"
  exit 1
fi
if ! echo "$hooks" | grep -q "mission-ops"; then
  echo "FAIL: the webhooks key does not mention mission-ops"
  exit 1
fi
if ! echo "$hooks" | grep -q "kube-system"; then
  echo "FAIL: kube-system was dropped from the webhooks key; a list you set replaces the old list"
  exit 1
fi

# The admission controller copies the selector to the live webhook configuration.
found=0
for _ in $(seq 1 30); do
  live=$(kubectl get validatingwebhookconfiguration kyverno-resource-validating-webhook-cfg \
    -o jsonpath='{.webhooks[*].namespaceSelector}' 2>/dev/null)
  if echo "$live" | grep -q "mission-ops"; then
    found=1
    break
  fi
  sleep 3
done
if [[ "$found" != 1 ]]; then
  echo "FAIL: the live validating webhook configuration does not skip mission-ops yet"
  exit 1
fi

echo "PASS: mission-ops is skipped by the webhooks and kube-system is kept."
exit 0
