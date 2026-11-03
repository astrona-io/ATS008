#!/usr/bin/env bash
# Status: UNTESTED (written statically, not yet run against a cluster).
#
# Seeds the finance namespace and a policy, then applies a broken revision 2:
# the admission controller image tag does not exist. No --wait is used, so
# Helm records revision 2 as deployed while the new Pod cannot pull its image.
set -eu

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

echo "Applying a broken revision 2 (missing admission controller image tag)..."
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
