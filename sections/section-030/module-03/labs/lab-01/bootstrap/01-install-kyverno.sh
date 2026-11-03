#!/usr/bin/env bash
# Lab start for "Webhooks, Failure Policy and Certificates Lab" (ats-008-lab-017).
#
# Status: UNTESTED (written statically, not yet run against a cluster).
#
# Adds the Kyverno Helm repository, installs Kyverno at default values, waits
# for the four controller Deployments and creates the namespace mission-ops.
# It also applies the ClusterPolicy audit-owner-label (Audit mode, matches Pods)
# so that Kyverno has a rule to register in its webhook configurations, and
# records the starting certificate serial in the ConfigMap lab-baseline.
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

echo "Applying the audit-owner-label policy (the webhook can need a moment)..."
applied=0
for _ in $(seq 1 40); do
  if kubectl apply -f "$SCRIPT_DIR/../manifests/audit-owner-label.yaml"; then
    applied=1
    break
  fi
  sleep 3
done
if [ "$applied" != 1 ]; then
  echo "Could not apply the audit-owner-label policy"
  exit 1
fi

echo "Waiting for Kyverno to register the policy in its webhook configuration..."
for _ in $(seq 1 40); do
  if kubectl get validatingwebhookconfiguration kyverno-resource-validating-webhook-cfg \
       -o jsonpath='{.webhooks[*].name}' 2>/dev/null | grep -q .; then
    break
  fi
  sleep 3
done



# Record the serial number of the admission controller certificate as it is now,
# so that the grader can tell when the certificate has been replaced.
echo "Recording the starting certificate..."
secret="kyverno-svc.kyverno.svc.kyverno-tls-pair"
for _ in $(seq 1 60); do
  if kubectl -n kyverno get secret "$secret" -o jsonpath='{.data.tls\.crt}' 2>/dev/null | grep -q .; then
    break
  fi
  sleep 3
done
serial=$(kubectl -n kyverno get secret "$secret" -o jsonpath='{.data.tls\.crt}' \
  | base64 -d | openssl x509 -noout -serial | cut -d= -f2)
kubectl -n default create configmap lab-baseline --from-literal=admissionCertSerial="$serial"
echo "Kyverno is ready at default values."
