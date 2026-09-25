#!/usr/bin/env bash
# Confirms the backup file exists and contains the pre-existing policy, the
# policy itself still exists post-upgrade, and the upgrade landed the new
# replica count / controller flag.

set -u

backup_file=""
for candidate in "$HOME/policy-backup.yaml" "/root/policy-backup.yaml" "./policy-backup.yaml"; do
  if [[ -f "$candidate" ]]; then
    backup_file="$candidate"
    break
  fi
done
if [[ -z "$backup_file" ]]; then
  found=$(find / -maxdepth 5 -name "policy-backup.yaml" 2>/dev/null | head -1)
  if [[ -n "$found" ]]; then
    backup_file="$found"
  fi
fi
if [[ -z "$backup_file" ]]; then
  echo "FAIL: policy-backup.yaml not found anywhere expected"
  exit 1
fi

if ! grep -q "require-cost-center-label" "$backup_file"; then
  echo "FAIL: $backup_file does not contain require-cost-center-label"
  exit 1
fi

if ! kubectl get clusterpolicy require-cost-center-label >/dev/null 2>&1; then
  echo "FAIL: require-cost-center-label ClusterPolicy no longer exists"
  exit 1
fi

replicas=$(kubectl get deploy kyverno-admission-controller -n kyverno -o jsonpath='{.spec.replicas}' 2>/dev/null)
if [[ "$replicas" != "3" ]]; then
  echo "FAIL: kyverno-admission-controller replicas is '$replicas', expected 3"
  exit 1
fi

bg_args=$(kubectl get deploy kyverno-background-controller -n kyverno -o jsonpath='{.spec.template.spec.containers[0].args}' 2>/dev/null)
if [[ "$bg_args" != *"--genWorkers=15"* ]]; then
  echo "FAIL: kyverno-background-controller args do not contain --genWorkers=15"
  exit 1
fi

history_lines=$(helm history kyverno -n kyverno 2>/dev/null | tail -n +2 | grep -c . || true)
if [[ -z "$history_lines" || "$history_lines" -lt 2 ]]; then
  echo "FAIL: helm history for release 'kyverno' shows fewer than 2 revisions"
  exit 1
fi

echo "PASS: backup file found at $backup_file, require-cost-center-label survived, admission replicas=3, --genWorkers=15 set, $history_lines revisions recorded."
exit 0
