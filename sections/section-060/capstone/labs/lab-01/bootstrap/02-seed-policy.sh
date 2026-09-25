#!/usr/bin/env bash
set -eu

kubectl create namespace finance --dry-run=client -o yaml | kubectl apply -f -

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
              - Pod
            namespaces:
              - finance
      validate:
        message: "A non-empty 'cost-center' label is required on every Pod in finance."
        pattern:
          metadata:
            labels:
              cost-center: "?*"
EOF

echo "finance namespace and require-cost-center-label policy seeded."
