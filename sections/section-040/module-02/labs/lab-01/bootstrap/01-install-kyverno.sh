#!/usr/bin/env bash
set -eu

echo "Adding the Kyverno Helm repo..."
helm repo add kyverno https://kyverno.github.io/kyverno/
helm repo update

echo "Installing Kyverno via Helm..."
helm install kyverno kyverno/kyverno -n kyverno --create-namespace

kubectl -n kyverno rollout status deployment/kyverno-admission-controller --timeout=180s
kubectl -n kyverno rollout status deployment/kyverno-background-controller --timeout=180s
kubectl -n kyverno rollout status deployment/kyverno-reports-controller --timeout=180s
kubectl -n kyverno rollout status deployment/kyverno-cleanup-controller --timeout=180s

echo "Kyverno is ready."
