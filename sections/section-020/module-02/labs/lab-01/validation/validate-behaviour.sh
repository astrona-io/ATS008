#!/usr/bin/env bash
# Creates matching and non-matching ConfigMaps, then polls (bounded) for the
# matching one to be removed by the learner's CleanupPolicy.

set -u

NS=salvage-yard
OTHER_NS=outpost
MAX_WAIT=200

cleanup_probes() {
  kubectl delete configmap grader-scrap grader-keep-unlabeled grader-keep-false -n "$NS" --ignore-not-found >/dev/null 2>&1
  kubectl delete configmap grader-keep-other-ns -n "$OTHER_NS" --ignore-not-found >/dev/null 2>&1
}
trap cleanup_probes EXIT

cleanup_probes

kubectl create configmap grader-scrap -n "$NS" --from-literal=note=match >/dev/null
kubectl label configmap grader-scrap -n "$NS" scrap=true >/dev/null
kubectl create configmap grader-keep-unlabeled -n "$NS" --from-literal=note=keep >/dev/null
kubectl create configmap grader-keep-false -n "$NS" --from-literal=note=keep >/dev/null
kubectl label configmap grader-keep-false -n "$NS" scrap=false >/dev/null
kubectl create configmap grader-keep-other-ns -n "$OTHER_NS" --from-literal=note=keep >/dev/null
kubectl label configmap grader-keep-other-ns -n "$OTHER_NS" scrap=true >/dev/null

waited=0
while kubectl get configmap grader-scrap -n "$NS" >/dev/null 2>&1; do
  if (( waited >= MAX_WAIT )); then
    echo "FAIL: grader-scrap (label scrap=true) was still in $NS after ${MAX_WAIT}s. Check the permission, the schedule and the policy match."
    exit 1
  fi
  sleep 5
  waited=$((waited + 5))
done

for name in grader-keep-unlabeled grader-keep-false; do
  if ! kubectl get configmap "$name" -n "$NS" >/dev/null 2>&1; then
    echo "FAIL: $name was deleted, but only ConfigMaps with scrap=true may be removed"
    exit 1
  fi
done

if ! kubectl get configmap grader-keep-other-ns -n "$OTHER_NS" >/dev/null 2>&1; then
  echo "FAIL: a ConfigMap in $OTHER_NS was deleted, but the policy must only act in $NS"
  exit 1
fi

echo "PASS: the labelled ConfigMap was removed within ${waited}s and every other ConfigMap was kept."
exit 0
