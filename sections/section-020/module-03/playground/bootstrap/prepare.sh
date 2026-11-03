#!/usr/bin/env bash
# Playground start for the policy report module.
# Status: UNTESTED (written statically, not yet run against a cluster).
set -eu

echo "[playground] Adding the Kyverno Helm repository..."
helm repo add kyverno https://kyverno.github.io/kyverno/
helm repo update

echo "[playground] Installing Kyverno with default values..."
helm install kyverno kyverno/kyverno -n kyverno --create-namespace

for deploy in kyverno-admission-controller kyverno-background-controller kyverno-cleanup-controller kyverno-reports-controller; do
  kubectl -n kyverno rollout status "deployment/${deploy}" --timeout=300s
done

kubectl create namespace hangar --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace depot --dry-run=client -o yaml | kubectl apply -f -
kubectl label namespace hangar env=prod --overwrite

# Wait until the policy CRDs accept objects and the webhooks are ready.
for i in $(seq 1 30); do
  if kubectl get crd clusterpolicies.kyverno.io >/dev/null 2>&1; then break; fi
  sleep 2
done
sleep 15

kubectl apply -f - <<'POLICY'
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: require-crew-labels
spec:
  background: true
  rules:
    - name: check-owner-label
      match:
        any:
          - resources:
              kinds:
                - Deployment
              namespaces:
                - hangar
      validate:
        failureAction: Audit
        message: "The label owner is required."
        pattern:
          metadata:
            labels:
              owner: "?*"
    - name: check-team-label
      match:
        any:
          - resources:
              kinds:
                - Deployment
              namespaces:
                - hangar
      validate:
        failureAction: Audit
        message: "The label team is required."
        pattern:
          metadata:
            labels:
              team: "?*"
---
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: require-planet-env
spec:
  background: true
  rules:
    - name: check-env-label
      match:
        any:
          - resources:
              kinds:
                - Namespace
              names:
                - hangar
                - depot
      validate:
        failureAction: Audit
        message: "The label env is required."
        pattern:
          metadata:
            labels:
              env: "?*"
POLICY

deploy() {
  name="$1"; shift
  kubectl apply -f - <<DEP
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ${name}
  namespace: hangar
$(if [ "$#" -gt 0 ]; then echo "  labels:"; for kv in "$@"; do echo "    ${kv%%=*}: ${kv#*=}"; done; fi)
spec:
  replicas: 1
  selector:
    matchLabels:
      app: ${name}
  template:
    metadata:
      labels:
        app: ${name}
    spec:
      containers:
        - name: pause
          image: registry.k8s.io/pause:3.10
DEP
}

deploy falcon owner=crew team=alpha
deploy comet team=alpha
deploy nova
deploy pulsar owner=crew

echo "[playground] Ready: Kyverno installed, hangar holds falcon, comet, nova and pulsar, policies are in Audit mode."
