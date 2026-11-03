#!/usr/bin/env bash
# Environment prep for the "Tuning Kyverno's Controllers with Flags"
# playground (`ats-008-playground-030-01`).
#
# Status: UNTESTED (written statically, not yet run against a cluster).
#
# Environment preparation only. There is no task and no grading. This script
# adds the Kyverno Helm repository, installs Kyverno at default values and waits
# for the four controller Deployments.
set -euo pipefail

echo "[playground] Adding the Kyverno Helm repository..."
helm repo add kyverno https://kyverno.github.io/kyverno/
helm repo update

echo "[playground] Installing Kyverno at default values..."
helm install kyverno kyverno/kyverno -n kyverno --create-namespace

for deploy in kyverno-admission-controller kyverno-background-controller kyverno-cleanup-controller kyverno-reports-controller; do
  kubectl -n kyverno rollout status "deployment/${deploy}" --timeout=300s
done

echo "[playground] Ready."
