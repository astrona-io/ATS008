#!/usr/bin/env bash
set -eu

# This generate rule fires on every new Namespace and tries to create a
# default-deny NetworkPolicy named "default-deny" inside it. The background
# controller's ServiceAccount is deliberately NOT granted permission on
# `networkpolicies` by this script -- the rule will silently fail to
# generate until the learner adds a correctly-labeled, aggregated
# ClusterRole. This mirrors the module lab's pattern for a different
# resource kind, reinforcing that the fix generalizes.

cat <<'EOF' | kubectl apply -f -
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: generate-network-policy
spec:
  rules:
    - name: generate-default-deny-per-namespace
      match:
        any:
        - resources:
            kinds:
              - Namespace
      exclude:
        any:
        - resources:
            namespaces:
              - kube-system
              - kube-node-lease
              - kube-public
              - kyverno
      generate:
        apiVersion: networking.k8s.io/v1
        kind: NetworkPolicy
        name: default-deny
        namespace: "{{request.object.metadata.name}}"
        synchronize: true
        data:
          spec:
            podSelector: {}
            policyTypes:
              - Ingress
              - Egress
EOF

echo "generate-network-policy ClusterPolicy applied."
