#!/usr/bin/env bash
# An ordinary Pod without an owner label must be accepted in the default
# namespace. While the require-owner-label policy or a leftover webhook is
# active, the request is refused. Retries for up to 60 seconds.

set -u

pod_name="removal-check"
kubectl delete pod "$pod_name" -n default --ignore-not-found --wait=true >/dev/null 2>&1

accepted=false
last_output=""
for i in $(seq 1 12); do
  if last_output=$(kubectl run "$pod_name" -n default --image=registry.k8s.io/pause:3.9 --restart=Never 2>&1); then
    accepted=true
    break
  fi
  sleep 5
done

kubectl delete pod "$pod_name" -n default --ignore-not-found --wait=false >/dev/null 2>&1

if [[ "$accepted" != "true" ]]; then
  echo "FAIL: a Pod without an owner label was refused: $last_output"
  exit 1
fi

echo "PASS: an ordinary Pod can be created."
exit 0
