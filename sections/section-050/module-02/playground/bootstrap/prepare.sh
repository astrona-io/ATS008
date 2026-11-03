#!/usr/bin/env bash
# Status: UNTESTED (written statically, not yet run against a cluster).
# Starting state for playground ats-008-playground-050-02: Kyverno installed
# with Helm at default values (release kyverno, namespace kyverno).
set -eu

echo "[playground] Adding the Kyverno Helm repository..."
helm repo add kyverno https://kyverno.github.io/kyverno/
helm repo update

echo "[playground] Installing Kyverno at default values..."
helm install kyverno kyverno/kyverno -n kyverno --create-namespace --wait --timeout 5m

for d in kyverno-admission-controller kyverno-background-controller kyverno-reports-controller kyverno-cleanup-controller; do
  kubectl -n kyverno rollout status "deployment/$d" --timeout=300s
done

echo "[playground] Ready."
