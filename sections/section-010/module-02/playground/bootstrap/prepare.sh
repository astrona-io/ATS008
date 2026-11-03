#!/usr/bin/env bash
# Environment prep for the playground `ats-008-playground-010-02`.
# Starting state: Kyverno installed with Helm as release `kyverno` in namespace
# `kyverno` (latest chart, default values) and the ClusterPolicy
# `require-owner-label`. There is no task and no grading.
#
# Status: UNTESTED (written statically, not yet run against a cluster).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "[playground] Adding the kyverno Helm repo..."
helm repo add kyverno https://kyverno.github.io/kyverno/
helm repo update

echo "[playground] Installing Kyverno with Helm..."
helm upgrade --install kyverno kyverno/kyverno -n kyverno --create-namespace --wait --timeout 5m

for d in kyverno-admission-controller kyverno-background-controller kyverno-reports-controller kyverno-cleanup-controller; do
  kubectl -n kyverno rollout status "deployment/$d" --timeout=300s
done
kubectl wait --for=condition=Established crd/clusterpolicies.kyverno.io --timeout=120s

echo "[playground] Applying the require-owner-label policy..."
# The webhook can need a moment before it accepts policies.
applied=false
for i in $(seq 1 40); do
  if kubectl apply -f "$SCRIPT_DIR/../manifests/require-owner-label.yaml"; then
    applied=true
    break
  fi
  sleep 3
done
if [ "$applied" != "true" ]; then
  echo "[playground] The policy was not accepted in time" >&2
  exit 1
fi

echo "[playground] Ready."
