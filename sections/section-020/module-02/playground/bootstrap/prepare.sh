#!/usr/bin/env bash
# Playground start for the cleanup module.
# Status: UNTESTED (written statically, not yet run against a cluster).
set -eu

echo "[playground] Adding the Kyverno Helm repository..."
helm repo add kyverno https://kyverno.github.io/kyverno/
helm repo update

echo "[playground] Installing Kyverno with default values..."
helm install kyverno kyverno/kyverno -n kyverno --create-namespace

for deploy in kyverno-admission-controller kyverno-background-controller kyverno-cleanup-controller kyverno-reports-controller; do
  kubectl -n kyverno rollout status "deployment/${deploy}" --timeout=300s
done

kubectl create namespace docking-bay --dry-run=client -o yaml | kubectl apply -f -
kubectl create configmap old-scrap -n docking-bay --from-literal=note=junk --dry-run=client -o yaml | kubectl apply -f -
kubectl create configmap keep-me -n docking-bay --from-literal=note=important --dry-run=client -o yaml | kubectl apply -f -
kubectl label configmap old-scrap -n docking-bay scrap=true --overwrite

echo "[playground] Ready: Kyverno installed, docking-bay holds old-scrap (scrap=true) and keep-me."
