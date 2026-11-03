#!/usr/bin/env bash
# Lab start for "The Kyverno ConfigMap Lab" (ats-008-lab-016).
#
# Status: UNTESTED (written statically, not yet run against a cluster).
#
# Adds the Kyverno Helm repository, installs Kyverno at default values, waits
# for the four controller Deployments and creates the namespace mission-ops.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Adding the Kyverno Helm repository..."
helm repo add kyverno https://kyverno.github.io/kyverno/
helm repo update

echo "Installing Kyverno at default values..."
helm install kyverno kyverno/kyverno -n kyverno --create-namespace

for deploy in kyverno-admission-controller kyverno-background-controller kyverno-cleanup-controller kyverno-reports-controller; do
  kubectl -n kyverno rollout status "deployment/${deploy}" --timeout=300s
done

kubectl apply -f "$SCRIPT_DIR/../manifests/mission-ops.yaml"

echo "Kyverno is ready at default values."
