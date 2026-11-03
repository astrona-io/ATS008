#!/usr/bin/env bash
# Status: UNTESTED (written statically, not yet run against a cluster).
# Starting state for playground ats-008-playground-050-01: the Kyverno Helm
# repository is added; Kyverno is NOT installed.
set -eu

echo "[playground] Adding the Kyverno Helm repository..."
helm repo add kyverno https://kyverno.github.io/kyverno/
helm repo update

echo "[playground] Ready. Kyverno is not installed yet."
