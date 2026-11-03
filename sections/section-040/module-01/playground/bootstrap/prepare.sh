#!/usr/bin/env bash
# Environment prep for the "Kyverno's RBAC Model" playground
# (`ats-008-playground-040-01`).
# Status: UNTESTED (written statically, not yet run against a cluster).
#
# Environment preparation only - there is no task and no grading. This script:
#   1. adds the Kyverno Helm repository and installs the latest chart as
#      release `kyverno` in namespace `kyverno`,
#   2. applies the ClusterPolicy generate-default-quota (Kyverno checks the
#      background controller's permissions when it accepts a generate policy,
#      so the policy goes in while the chart's default grant is still there),
#   3. upgrades the release with backgroundController.rbac.coreClusterRole
#      .extraResources emptied, which removes the create/update/patch/delete
#      permissions the chart gives by default for kinds such as ResourceQuota.
set -euo pipefail

echo "[playground] Adding the Kyverno Helm repository..."
helm repo add kyverno https://kyverno.github.io/kyverno/
helm repo update

echo "[playground] Installing Kyverno with Helm..."
helm install kyverno kyverno/kyverno -n kyverno --create-namespace
for d in kyverno-admission-controller kyverno-background-controller kyverno-reports-controller kyverno-cleanup-controller; do
  kubectl -n kyverno rollout status "deployment/$d" --timeout=300s
done

echo "[playground] Applying the generate-default-quota ClusterPolicy..."
for i in $(seq 1 40); do
  if kubectl apply -f - <<'POLICY'
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
POLICY
  then
    break
  fi
  sleep 3
done

echo "[playground] Removing the chart's default extra permissions of the background controller..."
cat > /tmp/ats008-no-extra-resources.yaml <<'VALUES'
backgroundController:
  rbac:
    coreClusterRole:
      extraResources: []
VALUES
helm upgrade kyverno kyverno/kyverno -n kyverno --reuse-values -f /tmp/ats008-no-extra-resources.yaml
kubectl -n kyverno rollout status deployment/kyverno-background-controller --timeout=300s

for i in $(seq 1 60); do
  answer="$(kubectl auth can-i create resourcequotas --as=system:serviceaccount:kyverno:kyverno-background-controller || true)"
  if [ "$answer" = "no" ]; then
    break
  fi
  sleep 2
done
echo "[playground] Ready."
