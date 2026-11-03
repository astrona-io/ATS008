# Background Scans and Intermediate Reports

Report cards do not appear by magic. Two things fill them: the inspectors at the launch gate, and a patrol that checks ships already in orbit. Between the inspectors and the cards sit scratch notes, the intermediate reports. This part shows the path and the dials on it.

## Who writes what

Which part does the work? The admission controller (the inspectors at the gate) writes a scratch note for each request it checks. The reports controller (the records office) runs the background scan: it patrols objects that already exist and writes scratch notes for them too. The reports controller then merges all notes into `PolicyReport` and `ClusterPolicyReport` objects and deletes the notes.

The scratch notes are `EphemeralReport` (one planet) and `ClusterEphemeralReport` (the solar system), in the group `reports.kyverno.io`. Older releases used `AdmissionReport` and `BackgroundScanReport`. A policy joins the background scan only when `spec.background` is `true`, which is the default.

## See it in your playground

<!-- astrona:playground:renew -->

Look for scratch notes:

```sh
kubectl get ephemeralreport -A
kubectl get clusterephemeralreport
```

Expect few or no lines, because the reports controller merges and deletes the notes quickly. Read the dials of the records office:

```sh
kubectl get deployment kyverno-reports-controller -n kyverno -o jsonpath='{.spec.template.spec.containers[0].args}'
```

Find `--aggregateReports=true`, `--backgroundScan=true`, `--backgroundScanWorkers=2` and `--backgroundScanInterval=1h`. The interval is one hour by default. In the chart it is the value `reportsController.backgroundScanInterval`, and it sets how often the patrol re-checks every object.

## Reports follow the objects

A report also changes when an object changes, without waiting for the hour. Fix `comet`, which lacks an `owner` label, by adding it:

```sh
kubectl label deployment comet -n hangar owner=crew
```

Then read the reports again and look at `comet`:

```sh
kubectl get policyreport -n hangar -o jsonpath='{range .items[*]}{.scope.name}{" fail="}{.summary.fail}{"\n"}{end}'
```

The fail counter of `comet` should drop after a short time. The change was caught by the admission controller, not by the hourly patrol.

## Common pitfalls

> [!WARNING]
> - **Debugging from `EphemeralReport` objects.** They are merged and deleted in moments. Read `PolicyReport`.
> - **Waiting an hour for a change to show.** Changes to an object update its report quickly. The interval is for the full patrol.
> - **Setting `background: false` and expecting reports for old objects.** Without background, existing objects are never patrolled.
> - **Reading old kind names in older material.** On this chart the notes are `EphemeralReport`, not `AdmissionReport`.
