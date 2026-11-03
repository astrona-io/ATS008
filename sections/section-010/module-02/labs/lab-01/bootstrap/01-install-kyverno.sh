#!/usr/bin/env bash
set -eu

echo "Adding the kyverno Helm repo..."
helm repo add kyverno https://kyverno.github.io/kyverno/
helm repo update

echo "Installing Kyverno with Helm..."
helm upgrade --install kyverno kyverno/kyverno -n kyverno --create-namespace --wait --timeout 5m

for deploy in kyverno-admission-controller kyverno-background-controller kyverno-reports-controller kyverno-cleanup-controller; do
  kubectl -n kyverno rollout status "deployment/${deploy}" --timeout=300s
done
kubectl wait --for=condition=Established crd/clusterpolicies.kyverno.io --timeout=120s

echo "Kyverno is ready."
