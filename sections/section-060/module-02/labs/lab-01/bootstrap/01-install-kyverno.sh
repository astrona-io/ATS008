#!/usr/bin/env bash
# Status: UNTESTED (written statically, not yet run against a cluster).
set -eu

echo "Adding the Kyverno Helm repo..."
helm repo add kyverno https://kyverno.github.io/kyverno/
helm repo update

echo "Installing Kyverno at default values (revision 1)..."
helm install kyverno kyverno/kyverno -n kyverno --create-namespace

for deploy in kyverno-admission-controller kyverno-background-controller kyverno-cleanup-controller kyverno-reports-controller; do
  kubectl -n kyverno rollout status "deployment/${deploy}" --timeout=300s
done

echo "Kyverno revision 1 is installed and ready."
