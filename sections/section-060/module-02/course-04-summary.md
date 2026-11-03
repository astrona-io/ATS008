# Summary

A bad refit is not the end of the mission. Helm keeps the flight record, and a rollback returns the station to an earlier design as a new entry in that record.

## What you learned

[Reading the History and Rolling Back](./course-01-reading-the-history-and-rolling-back.md) showed that Helm marks an upgrade `deployed` without waiting for the Pods unless you pass `--wait` (and `--timeout`). `helm history` lists the revisions, `helm get values --revision 2` shows what a revision asked for, and `helm rollback kyverno 1 -n kyverno --wait` returns to revision 1 by adding revision 3. You prove it with `helm history`, `helm status` and rollout checks.

[What a Rollback Keeps, and Backing Up Policies](./course-02-what-a-rollback-keeps-and-backing-up-policies.md) showed that a rollback puts back the controllers and the CRDs of the chosen revision, but does not touch policies or exceptions, because they are not in the release. A backup from `kubectl get ... -o yaml` is for reading and comparing; before you create objects from it, remove `resourceVersion`, `uid`, `creationTimestamp`, `generation`, `managedFields` and `status`.

[Values, Version Skew and the Pre-Upgrade Checklist](./course-03-values-version-skew-and-the-pre-upgrade-checklist.md) compared `--reuse-values`, `--reset-values` and `--reset-then-reuse-values`, showed the chart's `kubeVersion` limit and gave the eight-step pre-upgrade checklist.

## Missions

| Mission | What it proves |
| --- | --- |
| Rolling Back a Bad Kyverno Upgrade Lab (`ats-008-lab-020`) | You roll a broken revision 2 back to revision 1, the admission controller is healthy and the history shows the rollback |

## Check yourself

- Why can `helm history` say `deployed` while a Pod cannot start?
- What does `helm rollback kyverno 1` add to the history?
- Which objects does a rollback leave alone?
- What does `--reset-values` do to a value you did not type again?
- Where do you read the Kubernetes versions a chart accepts?

Clean up the playground when you are done:

```sh
astrona list
astrona destroy ats-008-playground-060-02
```

<!-- astrona:playground:destroy -->
