#!/usr/bin/env bash
# Creates the namespaces, the Audit policies and the Deployments for the report
# lab. The learner only reads the reports and never changes these objects.
set -eu

kubectl create namespace shipyard --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace drydock --dry-run=client -o yaml | kubectl apply -f -
kubectl label namespace shipyard env=prod --overwrite

for i in $(seq 1 30); do
  if kubectl get crd clusterpolicies.kyverno.io >/dev/null 2>&1; then break; fi
  sleep 2
done
sleep 15

kubectl apply -f - <<'POLICY'
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: require-fleet-labels
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
                - shipyard
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
                - shipyard
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
  name: require-yard-env
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
                - shipyard
                - drydock
      validate:
        failureAction: Audit
        message: "The label env is required."
        pattern:
          metadata:
            labels:
              env: "?*"
POLICY

make_deploy() {
  name="$1"; shift
  {
    echo "apiVersion: apps/v1"
    echo "kind: Deployment"
    echo "metadata:"
    echo "  name: ${name}"
    echo "  namespace: shipyard"
    if [ "$#" -gt 0 ]; then
      echo "  labels:"
      for kv in "$@"; do echo "    ${kv%%=*}: ${kv#*=}"; done
    fi
    echo "spec:"
    echo "  replicas: 1"
    echo "  selector:"
    echo "    matchLabels:"
    echo "      app: ${name}"
    echo "  template:"
    echo "    metadata:"
    echo "      labels:"
    echo "        app: ${name}"
    echo "    spec:"
    echo "      containers:"
    echo "        - name: pause"
    echo "          image: registry.k8s.io/pause:3.10"
  } | kubectl apply -f -
}

make_deploy scout owner=crew team=alpha
make_deploy probe team=alpha
make_deploy relay
make_deploy shuttle owner=crew

# Wait (bounded) until the reports exist so the learner starts with data.
for i in $(seq 1 60); do
  n=$(kubectl get policyreport -n shipyard --no-headers 2>/dev/null | wc -l | tr -d ' ')
  if [ "${n:-0}" -ge 4 ]; then break; fi
  sleep 5
done

echo "Seeded: shipyard holds scout, probe, relay and shuttle. Policies are in Audit mode."
