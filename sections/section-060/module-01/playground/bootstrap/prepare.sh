#!/usr/bin/env bash
# Status: UNTESTED (written statically, not yet run against a cluster).
#
# Environment prep for the "Upgrading a Running Kyverno Installation"
# playground (`ats-008-playground-060-01`). There is no task and no grading.
# This script adds the kyverno Helm repository, installs Kyverno at the
# chart's default values and waits until all four controllers are ready.
set -eu

echo "[playground] Adding the Kyverno Helm repository..."
helm repo add kyverno https://kyverno.github.io/kyverno/
helm repo update

echo "[playground] Installing Kyverno at default values (revision 1)..."
helm install kyverno kyverno/kyverno -n kyverno --create-namespace

for deploy in kyverno-admission-controller kyverno-background-controller kyverno-cleanup-controller kyverno-reports-controller; do
  kubectl -n kyverno rollout status "deployment/${deploy}" --timeout=300s
done

echo "[playground] Ready: release kyverno is at revision 1."
