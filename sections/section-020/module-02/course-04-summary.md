# Summary

Kyverno's cleanup controller is the salvage crew. It removes old objects, either by a schedule that you write or by a label on one object.

## What you learned

- **Cleanup policies.** `CleanupPolicy` (one planet) and `ClusterCleanupPolicy` (the whole solar system) use `apiVersion: kyverno.io/v2` and need `match` and `schedule`. `exclude` and `conditions` narrow the list, and conditions read the object as `target`. See [Cleanup Policies: The Salvage Schedule](./course-01-cleanup-policies-the-salvage-schedule.md).
- **The time-to-live label.** `cleanup.kyverno.io/ttl` gives one object its own expiry, with a duration or a date. The check runs on the interval set by `--ttlReconciliationInterval`, one minute by default. See [The Time-to-Live Label](./course-02-the-time-to-live-label.md).
- **Clearance and checking.** The cleanup controller needs delete permission through a `ClusterRole` labelled `rbac.kyverno.io/aggregate-to-cleanup-controller: "true"`. You prove a run with `kubectl auth can-i`, the policy's `status.lastExecutionTime` and the controller log. See [Clearance for the Salvage Crew and Checking That It Ran](./course-03-clearance-for-the-salvage-crew-and-checking-it-ran.md).

## Missions

| Mission | What it asks | Lab name |
| --- | --- | --- |
| Cleanup Policy Lab | Grant the crew clearance for ConfigMaps and write a `CleanupPolicy` that removes labelled ConfigMaps every minute | `ats-008-lab-014` |

## Check yourself

- Which field is required next to `match` in a cleanup policy?
- Your policy is applied, the schedule is every minute, and nothing is deleted. What do you check first?
- How long can an object with `cleanup.kyverno.io/ttl=2m` live at most, with the default interval?
- What is the difference between `CleanupPolicy` and `ClusterCleanupPolicy`?

When you have finished, clean up the playground. List what is running, then destroy it:

```sh
astrona list
astrona destroy ats-008-playground-020-02
```

<!-- astrona:playground:destroy -->
