#!/usr/bin/env bash
set -eu

# The webhook can need a moment before it accepts policies.
applied=false
for i in $(seq 1 40); do
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
    applied=true
    break
  fi
  sleep 3
done

if [ "$applied" != "true" ]; then
  echo "The require-owner-label policy was not accepted in time" >&2
  exit 1
fi

echo "require-owner-label policy ready."
