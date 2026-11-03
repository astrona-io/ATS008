#!/usr/bin/env bash
# No validating or mutating webhook configuration with "kyverno" in its name.
# Whether Helm's cleanup hook or the learner removed them does not matter.

set -u

if ! out=$(kubectl get validatingwebhookconfigurations,mutatingwebhookconfigurations -o name 2>&1); then
  echo "FAIL: could not list webhook configurations: $out"
  exit 1
fi

left=$(echo "$out" | grep -i kyverno || true)
if [[ -n "$left" ]]; then
  echo "FAIL: webhook configurations with kyverno in the name remain:"
  echo "$left"
  exit 1
fi

echo "PASS: no Kyverno webhook configuration remains."
exit 0
