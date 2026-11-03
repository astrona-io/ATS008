#!/usr/bin/env bash
# Environment prep for the playground `ats-008-playground-010-01`.
# Starting state: the kyverno Helm repository is added, Kyverno is NOT
# installed. There is no task and no grading.
#
# Status: UNTESTED (written statically, not yet run against a cluster).
set -eu

echo "[playground] Adding the kyverno Helm repo..."
helm repo add kyverno https://kyverno.github.io/kyverno/
helm repo update

echo "[playground] Ready. Kyverno is NOT installed."
