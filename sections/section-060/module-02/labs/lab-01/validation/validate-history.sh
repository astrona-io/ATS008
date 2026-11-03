#!/usr/bin/env bash
# Status: UNTESTED (written statically, not yet run against a cluster).
# Helm records a rollback as a NEW revision at the end of the history. The
# newest revision is `deployed` with a rollback description, and revision 2
# (the broken upgrade) is `superseded`. Rows of `helm history` start with the
# revision number.
set -u

history=$(helm history kyverno -n kyverno 2>/dev/null | tail -n +2)
count=$(printf '%s\n' "$history" | grep -c . || true)
if [[ "$count" -lt 3 ]]; then
  echo "FAIL: helm history shows $count revision(s), expected at least 3 (install, broken upgrade, rollback)"
  exit 1
fi

last=$(printf '%s\n' "$history" | grep . | tail -n 1)
if ! grep -q "deployed" <<<"$last"; then
  echo "FAIL: the newest revision is not deployed: $last"
  exit 1
fi
if ! grep -Eqi "roll(ed)? ?back" <<<"$last"; then
  echo "FAIL: the newest revision is not a rollback: $last"
  exit 1
fi

second=$(printf '%s\n' "$history" | awk '$1 == 2')
if ! grep -q "superseded" <<<"$second"; then
  echo "FAIL: revision 2 is not superseded: ${second:-not found}"
  exit 1
fi

echo "PASS: $count revisions, the newest is a deployed rollback and revision 2 is superseded."
exit 0
