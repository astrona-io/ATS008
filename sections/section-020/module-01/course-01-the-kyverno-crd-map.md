# The Kyverno CRD Map

A custom resource definition (CRD) is a new kind of form that mission control's registry desk learns to accept. Once the desk knows the form, you can file it with `kubectl` like any built-in object. Kyverno installs a whole set of these forms. This part shows you how to list them, read their versions and read their fields, so you never have to guess what a cluster accepts.

## Two families of forms

Kyverno's forms fall into two families. You write the first family. Kyverno's crews write the second one.

| You write these | Kyverno writes these |
| --- | --- |
| `ClusterPolicy` and `Policy` (rule books) | `PolicyReport` and `ClusterPolicyReport` (report cards) |
| `PolicyException` (a signed waiver) | `EphemeralReport` and `ClusterEphemeralReport` (scratch notes) |
| `CleanupPolicy` and `ClusterCleanupPolicy` (salvage schedules) | `UpdateRequest` (a work order in the construction crew's queue) |
| `GlobalContextEntry` (a shared star chart) | |

The old names `AdmissionReport` and `BackgroundScanReport` belonged to older releases. This module runs v1.13.2, and on that release the scratch notes are `EphemeralReport` objects.

## See it in your playground

<!-- astrona:playground:renew -->

List every Kyverno form on the cluster:

```sh
kubectl get crd | grep kyverno.io
```

You should see the rule books, the exception, the cleanup policies, the global context entry, the update request and the ephemeral reports. The report cards are not in this list, because their API group is `wgpolicyk8s.io`, a shared reporting group and not a Kyverno one. List them with a second search:

```sh
kubectl get crd | grep -E "kyverno.io|wgpolicyk8s.io"
```

The second list adds `policyreports.wgpolicyk8s.io` and `clusterpolicyreports.wgpolicyk8s.io`. The first column is the CRD name: the plural kind, a dot, then the API group.

## Scope: a planet or the whole solar system

Some forms belong to one planet (a namespace). Others belong to the whole solar system (the cluster). `kubectl api-resources` shows which is which in the `NAMESPACED` column:

```sh
kubectl api-resources --api-group=kyverno.io
```

Look at three things in the table. The `SHORTNAMES` column holds short typing aids such as `cpol` for `ClusterPolicy`. The `APIVERSION` column says which version `kubectl` uses by default. The `NAMESPACED` column says `true` for a `Policy` and `false` for a `ClusterPolicy`.

## Versions and fields

One kind can have several versions at once. The version you write in `apiVersion:` must be one the cluster serves. Read the served versions of the `PolicyException` form:

```sh
kubectl get crd policyexceptions.kyverno.io -o jsonpath='{.spec.versions[*].name}'
```

The command prints the version names on one line. Use the newest one that is not marked as deprecated. On Kyverno v1.13.2 the `PolicyException` form is in the `kyverno.io` group. The separate `policies.kyverno.io` API group does not exist on this release.

To read the fields of a form, ask the registry desk with `kubectl explain`:

```sh
kubectl explain policyexception.spec
```

`kubectl explain` reads the schema of the version that is really installed. It tells you which fields exist and which ones are required, so it is the safest source when a field name in a book disagrees with your cluster.

## The rule books you already know

`ClusterPolicy` (the whole solar system) and `Policy` (one planet) are the two forms that hold `spec.rules`. A rule has a `match` block that picks the ships to check and one action, such as `validate`. Both use `apiVersion: kyverno.io/v1`. The playground already has one rule book. Look at it:

```sh
kubectl get clusterpolicy require-owner-label
```

The output has a `READY` column. It should be `True` before you rely on the policy.

## Common pitfalls

> [!WARNING]
> - **Looking for report cards in the `kyverno.io` group.** `PolicyReport` and `ClusterPolicyReport` live in `wgpolicyk8s.io`. A search for `kyverno.io` will not show them.
> - **Copying an `apiVersion` from a book for another release.** Read the served versions from the CRD on your own cluster.
> - **Confusing `Policy` with `ClusterPolicy`.** A `Policy` only acts on its own planet. A `ClusterPolicy` acts on all planets.
