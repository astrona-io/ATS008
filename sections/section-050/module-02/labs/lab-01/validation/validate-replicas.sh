#!/usr/bin/env bash
# Status: UNTESTED (written statically, not yet run against a cluster).
# Kyverno is a Helm release; admission has 3 and background has 2 replicas,
# all ready (bounded poll for the rollout).
set -u

if ! helm status kyverno -n kyverno >/dev/null 2>&1; then
  echo "FAIL: Helm release 'kyverno' not found in namespace kyverno"
  exit 1
fi

check_replicas() {
  local deploy="$1" expected="$2" spec ready i
  for i in $(seq 1 60); do
    spec=$(kubectl get deploy "$deploy" -n kyverno -o jsonpath='{.spec.replicas}' 2>/dev/null)
    ready=$(kubectl get deploy "$deploy" -n kyverno -o jsonpath='{.status.readyReplicas}' 2>/dev/null)
    if [[ "$spec" == "$expected" && "$ready" == "$expected" ]]; then
      return 0
    fi
    sleep 3
  done
  echo "FAIL: $deploy - expected $expected ready replicas, spec '$spec', ready '$ready'"
  exit 1
}

check_replicas kyverno-admission-controller 3
check_replicas kyverno-background-controller 2

echo "PASS: admission 3/3 and background 2/2 replicas are ready."
exit 0
