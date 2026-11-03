#!/usr/bin/env bash
# Environment prep for the "Permissions for the Cleanup, Reports and
# Admission Controllers" playground (`ats-008-playground-040-02`).
# Status: UNTESTED (written statically, not yet run against a cluster).
#
# Environment preparation only - there is no task and no grading. This script:
#   1. installs the latest kyverno/kyverno chart (default values) as release
#      `kyverno` in namespace `kyverno`,
#   2. creates namespace `debris` with ConfigMaps: old-log-1 and old-log-2
#      (label stale=true) and keep-log (label stale=false),
#   3. creates the CRD beacons.fleet.example.com, one Beacon `beacon-1` in
#      namespace `harbor` without an owner label, and the ClusterPolicy
#      beacons-need-owner (Audit mode).
set -euo pipefail

echo "[playground] Adding the Kyverno Helm repository..."
helm repo add kyverno https://kyverno.github.io/kyverno/
helm repo update

echo "[playground] Installing Kyverno with Helm..."
helm install kyverno kyverno/kyverno -n kyverno --create-namespace
for d in kyverno-admission-controller kyverno-background-controller kyverno-reports-controller kyverno-cleanup-controller; do
  kubectl -n kyverno rollout status "deployment/$d" --timeout=300s
done

echo "[playground] Creating the debris namespace and its ConfigMaps..."
kubectl create namespace debris
kubectl -n debris create configmap old-log-1 --from-literal=note=stale
kubectl -n debris create configmap old-log-2 --from-literal=note=stale
kubectl -n debris create configmap keep-log --from-literal=note=fresh
kubectl -n debris label configmap old-log-1 old-log-2 stale=true
kubectl -n debris label configmap keep-log stale=false

echo "[playground] Creating the Beacon custom resource..."
kubectl apply -f - <<'CRD'
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: beacons.fleet.example.com
spec:
  group: fleet.example.com
  scope: Namespaced
  names:
    kind: Beacon
    listKind: BeaconList
    plural: beacons
    singular: beacon
  versions:
    - name: v1
      served: true
      storage: true
      schema:
        openAPIV3Schema:
          type: object
          x-kubernetes-preserve-unknown-fields: true
CRD
kubectl wait --for=condition=Established crd/beacons.fleet.example.com --timeout=120s
kubectl create namespace harbor
kubectl apply -f - <<'BEACON'
apiVersion: fleet.example.com/v1
kind: Beacon
metadata:
  name: beacon-1
  namespace: harbor
spec:
  frequency: 42
BEACON

echo "[playground] Applying the beacons-need-owner policy (Audit mode)..."
for i in $(seq 1 40); do
  if kubectl apply -f - <<'POLICY'
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: beacons-need-owner
spec:
  background: true
  rules:
    - name: check-owner-label
      match:
        any:
          - resources:
              kinds:
                - fleet.example.com/v1/Beacon
      validate:
        failureAction: Audit
        message: "Beacons need an owner label."
        pattern:
          metadata:
            labels:
              owner: "?*"
POLICY
  then
    break
  fi
  sleep 3
done
echo "[playground] Ready."
