#!/usr/bin/env bash
# Playground start for "Kyverno's CRD Surface": the same starting state as the
# module lab. Status: UNTESTED (written statically, not yet run against a cluster).
set -eu

KYVERNO_VERSION="v1.13.2"

echo "[playground] Installing Kyverno ${KYVERNO_VERSION}..."
kubectl create -f "https://github.com/kyverno/kyverno/releases/download/${KYVERNO_VERSION}/install.yaml"

for deploy in kyverno-admission-controller kyverno-background-controller kyverno-cleanup-controller kyverno-reports-controller; do
  kubectl -n kyverno rollout status "deployment/${deploy}" --timeout=300s
done

kubectl create namespace checkout --dry-run=client -o yaml | kubectl apply -f -

# The webhook can need a moment before it accepts policies.
for attempt in $(seq 1 30); do
  if cat <<'POLICY' | kubectl apply -f -
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: require-owner-label
spec:
  validationFailureAction: Enforce
  background: true
  rules:
    - name: check-owner-label
      match:
        any:
          - resources:
              kinds:
                - Pod
      exclude:
        any:
          - resources:
              namespaces:
                - kube-system
                - kyverno
      validate:
        message: "A non-empty 'owner' label is required on every Pod."
        pattern:
          metadata:
            labels:
              owner: "?*"
POLICY
  then
    break
  fi
  sleep 3
done

echo "[playground] Ready: Kyverno ${KYVERNO_VERSION}, namespace checkout, ClusterPolicy require-owner-label."
