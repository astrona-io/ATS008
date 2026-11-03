#!/usr/bin/env bash
set -eu

# This generate rule fires on every new Namespace and tries to create a
# ResourceQuota named "default-quota" inside it. By the end of this script the
# background controller has no permission to create ResourceQuotas (see the
# helm upgrade below), so the rule fails until the learner adds a
# correctly-labelled, aggregated ClusterRole.

cat <<'EOF' | kubectl apply -f -
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: generate-default-quota
spec:
  rules:
    - name: generate-quota-per-namespace
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
        apiVersion: v1
        kind: ResourceQuota
        name: default-quota
        namespace: "{{request.object.metadata.name}}"
        synchronize: true
        data:
          spec:
            hard:
              pods: "10"
EOF

echo "generate-default-quota ClusterPolicy applied."

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
  answer="$(kubectl auth can-i create resourcequotas --as=system:serviceaccount:kyverno:kyverno-background-controller || true)"
  if [ "$answer" = "no" ]; then
    break
  fi
  sleep 2
done
echo "Background controller can no longer create resourcequotas."
