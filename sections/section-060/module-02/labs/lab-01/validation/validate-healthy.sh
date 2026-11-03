#!/usr/bin/env bash
# Status: UNTESTED (written statically, not yet run against a cluster).
# The admission controller no longer uses the missing image, every controller
# Deployment has all its replicas available, and no Pod has an image pull
# error. Polls for up to 120 seconds because a rollout needs time.
set -u

image=$(kubectl get deploy kyverno-admission-controller -n kyverno -o jsonpath='{.spec.template.spec.containers[0].image}' 2>/dev/null)
if [[ -z "$image" || "$image" == *"does-not-exist"* ]]; then
  echo "FAIL: kyverno-admission-controller still uses the missing image: '$image'"
  exit 1
fi

if helm get values kyverno -n kyverno -a 2>/dev/null | grep -q "does-not-exist"; then
  echo "FAIL: the release values still contain the missing image tag"
  exit 1
fi

last_problem=""
for i in $(seq 1 24); do
  last_problem=""
  for deploy in kyverno-admission-controller kyverno-background-controller kyverno-reports-controller kyverno-cleanup-controller; do
    wanted=$(kubectl get deploy "$deploy" -n kyverno -o jsonpath='{.spec.replicas}' 2>/dev/null)
    available=$(kubectl get deploy "$deploy" -n kyverno -o jsonpath='{.status.availableReplicas}' 2>/dev/null)
    updated=$(kubectl get deploy "$deploy" -n kyverno -o jsonpath='{.status.updatedReplicas}' 2>/dev/null)
    total=$(kubectl get deploy "$deploy" -n kyverno -o jsonpath='{.status.replicas}' 2>/dev/null)
    if [[ -z "$available" || "$available" != "$wanted" || "$updated" != "$wanted" || "$total" != "$wanted" ]]; then
      last_problem="$deploy is not fully available (wanted=$wanted available=${available:-0} updated=${updated:-0} total=${total:-0})"
    fi
  done
  if kubectl get pods -n kyverno --no-headers 2>/dev/null | grep -Eq "ErrImagePull|ImagePullBackOff|InvalidImageName"; then
    last_problem="a Pod in the kyverno namespace has an image pull error"
  fi
  if [[ -z "$last_problem" ]]; then
    echo "PASS: the admission controller uses $image and every controller is available."
    exit 0
  fi
  sleep 5
done

echo "FAIL: $last_problem"
exit 1
