# Generated CRDs: Reports and Queues

Every form in this part is written by Kyverno's crews, not by you. They are the paper trail of the inspections. You read them to learn what Kyverno decided. You almost never write one.

## Report cards: PolicyReport and ClusterPolicyReport

A `PolicyReport` is the report card for one planet (a namespace). A `ClusterPolicyReport` is the report card for the whole solar system. Both live in the API group `wgpolicyk8s.io`, version `v1alpha2`. That group is a shared standard for policy results and is not specific to Kyverno.

### See it in your playground

<!-- astrona:playground:renew -->

List the report cards on the `checkout` planet, and then for the solar system:

```sh
kubectl get policyreport -n checkout
kubectl get clusterpolicyreport
```

Each line is one object that Kyverno checked. The `PASS` and `FAIL` columns are counts. The lists can be empty on a fresh cluster. They fill in as ships are launched or scanned.

## Scratch notes: ephemeral reports

The inspectors do not write the report cards directly. The admission controller and the reports controller (the records office) first write short scratch notes: one per checked request or per scan. The reports controller then merges these notes into the report cards and throws them away. On v1.13.2 these notes are `EphemeralReport` (one planet) and `ClusterEphemeralReport` (the solar system), in the group `reports.kyverno.io`. Older releases used `AdmissionReport` and `BackgroundScanReport`.

Look at them:

```sh
kubectl get ephemeralreport -A
kubectl get clusterephemeralreport
```

Expect few or no lines, or lines that appear and vanish. That is normal: the notes live only until the next merge. If you need a lasting answer, read the report card, not the scratch notes.

## The work-order queue: UpdateRequest

An `UpdateRequest` is a work order waiting in the background controller's queue. The construction crew uses it for jobs such as creating a generated object or changing an existing one after launch. You may read one while you debug a `generate` rule that is slow to finish, but you never write one.

```sh
kubectl get updaterequest -A
```

The list is often empty, because finished work orders are removed.

## Listing everything Kyverno wrote

To see all the generated kinds with their scope and version in one table, ask for both report groups:

```sh
kubectl api-resources --api-group=wgpolicyk8s.io
kubectl api-resources --api-group=reports.kyverno.io
```

Check the `NAMESPACED` column to tell the planet-level forms from the solar-system ones.

## Common pitfalls

> [!WARNING]
> - **Debugging from the scratch notes.** `EphemeralReport` objects are merged and deleted quickly. They can look empty. Read `PolicyReport` or `ClusterPolicyReport`.
> - **Looking for `AdmissionReport` on this release.** v1.13.2 uses `EphemeralReport`. A command for the old kinds returns an error that the resource type does not exist.
> - **Writing or editing a generated object.** The crews overwrite it. Change the policy, not the report.
