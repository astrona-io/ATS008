#!/usr/bin/env bash
# Status: UNTESTED (written statically, not yet run against a cluster).
#
# Environment prep for the "Rolling Back and Recovering from a Bad Upgrade"
# playground (`ats-008-playground-060-02`). There is no task and no grading.
# It installs Kyverno at default values (revision 1), seeds the finance
# namespace and one policy, then applies a broken revision 2 without --wait.
set -eu

echo "[playground] Adding the Kyverno Helm repository..."
helm repo add kyverno https://kyverno.github.io/kyverno/
helm repo update

echo "[playground] Installing Kyverno at default values (revision 1)..."
helm install kyverno kyverno/kyverno -n kyverno --create-namespace

for deploy in kyverno-admission-controller kyverno-background-controller kyverno-cleanup-controller kyverno-reports-controller; do
  kubectl -n kyverno rollout status "deployment/${deploy}" --timeout=300s
done

kubectl create namespace finance --dry-run=client -o yaml | kubectl apply -f -

# The webhook may need a moment before it accepts policies.
for i in $(seq 1 30); do
  if cat <<'EOF2' | kubectl apply -f -
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
EOF2
  then
    break
  fi
  sleep 3
done

echo "[playground] Applying a broken revision 2 (missing admission controller image tag)..."
helm upgrade kyverno kyverno/kyverno -n kyverno --reuse-values \
  --set admissionController.container.image.tag=v0.0.0-does-not-exist

# Give the new Pod time to fail its image pull so the learner sees the problem.
for i in $(seq 1 30); do
  if kubectl get pods -n kyverno --no-headers 2>/dev/null | grep -Eq "ErrImagePull|ImagePullBackOff"; then
    break
  fi
  sleep 4
done

echo "Revision 2 is recorded; the new admission controller Pod cannot start."
