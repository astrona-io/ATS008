#!/usr/bin/env bash
set -eu

# Starting state: namespace scrap with three ConfigMaps. old-note-1 and
# old-note-2 carry the label expired=true and must be removed by the cleanup
# policy the learner writes. keep-note carries expired=false and must stay.
# The cleanup controller has no permission to delete ConfigMaps by default.

kubectl create namespace scrap
kubectl -n scrap create configmap old-note-1 --from-literal=note=stale
kubectl -n scrap create configmap old-note-2 --from-literal=note=stale
kubectl -n scrap create configmap keep-note --from-literal=note=fresh
kubectl -n scrap label configmap old-note-1 old-note-2 expired=true
kubectl -n scrap label configmap keep-note expired=false

echo "Namespace scrap is seeded."
