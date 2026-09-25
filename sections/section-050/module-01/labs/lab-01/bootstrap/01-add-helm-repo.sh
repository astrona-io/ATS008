#!/usr/bin/env bash
set -eu

echo "Adding the Kyverno Helm repo..."
helm repo add kyverno https://kyverno.github.io/kyverno/
helm repo update

echo "Repo ready. Kyverno is NOT installed yet — installing it for HA is your task."
