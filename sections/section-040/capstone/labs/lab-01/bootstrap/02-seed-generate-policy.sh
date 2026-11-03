#!/usr/bin/env bash
set -eu

# This generate rule fires on every new Namespace and tries to create a
# default-deny NetworkPolicy named "default-deny" inside it. By the end of this
# script the background controller has no permission to create NetworkPolicies
# (see the helm upgrade below), so the rule fails until the learner adds a
# correctly-labelled, aggregated ClusterRole.

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

# Kyverno checks the background controller's permissions when it accepts a
# generate policy, so the policy had to go in first. Now empty the chart's
# default list of extra permissions (create, update, patch and delete on kinds
# such as ResourceQuota and NetworkPolicy), so the grant the learner must add
# is really missing.
cat > /tmp/ats008-no-extra-resources.yaml <<'VALUES'
backgroundController:
  rbac:
    coreClusterRole:
      extraResources: []
VALUES
helm upgrade kyverno kyverno/kyverno -n kyverno --reuse-values -f /tmp/ats008-no-extra-resources.yaml
kubectl -n kyverno rollout status deployment/kyverno-background-controller --timeout=180s

for i in $(seq 1 60); do
  answer="$(kubectl auth can-i create networkpolicies.networking.k8s.io --as=system:serviceaccount:kyverno:kyverno-background-controller || true)"
  if [ "$answer" = "no" ]; then
    break
  fi
  sleep 2
done
echo "Background controller can no longer create networkpolicies.networking.k8s.io."
