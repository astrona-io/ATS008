# Overview: Permissions for the Cleanup, Reports and Admission Controllers (Playground)

This playground is a training solar system with Kyverno at default values. There is no grading. You use it to see what each crew may do, to watch two crews fail for lack of a clearance card, and to grant the cards.

## What's in the box

| Item | Detail |
| --- | --- |
| Helm release | `kyverno` in namespace `kyverno`, latest `kyverno/kyverno` chart, default values |
| Namespace `debris` | ConfigMaps `old-log-1` and `old-log-2` (label `stale=true`), and `keep-log` (label `stale=false`) |
| Custom resource | The kind `Beacon` (`beacons.fleet.example.com`), with one object `beacon-1` in namespace `harbor` and no `owner` label |
| `ClusterPolicy` | `beacons-need-owner`: a Beacon needs an `owner` label (`Audit` mode, also scanned in the background) |

No extra permissions are granted. The cleanup controller may not delete ConfigMaps, and the reports controller may not read Beacons.

## Helpers

```sh
can_do() {
  kubectl auth can-i "$1" "$2" --as="system:serviceaccount:kyverno:kyverno-$3-controller"
}
```

Use it as `can_do <verb> <resource> <controller>`, for example `can_do delete configmaps cleanup`. It prints `yes` or `no`. For a custom resource use the full name, for example `beacons.fleet.example.com`.

## Practice tasks

- Run `can_do` with `delete` and `pods` for all four controllers. Then run `kubectl auth can-i --list --as=system:serviceaccount:kyverno:kyverno-cleanup-controller`.
- Read the master and `:core` ClusterRoles for each controller and list which kinds each one may write.
- Save and apply a ClusterRole with the label `rbac.kyverno.io/aggregate-to-cleanup-controller: "true"` that allows `get`, `list` and `delete` on `configmaps`. Then save and apply a `ClusterCleanupPolicy` that removes the ConfigMaps in `debris` with `stale: "true"`. Wait for the next minute.
- Look for PolicyReport results for `beacon-1`. Find the "forbidden" message in the reports controller log. Grant `get`, `list` and `watch` on `beacons` to the reports controller with a labelled ClusterRole, then compare.
- Do the same grant again with the chart value `reportsController.rbac.clusterRole.extraResources` and `helm upgrade`, and compare the ClusterRole names.
- Run `can_do '*' '*'` for each controller. Every answer should be `no`.
