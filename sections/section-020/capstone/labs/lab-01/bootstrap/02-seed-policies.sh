#!/usr/bin/env bash
set -eu

kubectl create namespace checkout --dry-run=client -o yaml | kubectl apply -f -

cat <<'EOF' | kubectl apply -f -
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
EOF

cat <<'EOF' | kubectl apply -f -
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: require-cost-center-label
spec:
  validationFailureAction: Enforce
  background: true
  rules:
    - name: check-cost-center-label
      match:
        any:
          - resources:
              kinds:
                - Deployment
              namespaces:
                - checkout
      validate:
        message: "A non-empty 'cost-center' label is required on every Deployment in checkout."
        pattern:
          metadata:
            labels:
              cost-center: "?*"
EOF

echo "checkout namespace, require-owner-label, and require-cost-center-label ready."
