# Cleanup Policies and Global Context Entries

Two more forms are yours to write. A cleanup policy is a salvage schedule: it tells the cleanup controller (the salvage crew) which old ships to remove and when. A `GlobalContextEntry` is a shared star chart: one copy of some data, kept at the station, so that many rule books read it instead of each asking for it again. This part reads both forms on your cluster. It does not build a working salvage job.

## Cleanup policies: a salvage schedule

There are two kinds. `CleanupPolicy` works on one planet (a namespace). `ClusterCleanupPolicy` works on the whole solar system. Both are in the `kyverno.io` group and both need two fields: `match`, which picks the objects, and `schedule`, a cron expression that says when the salvage crew runs.

Here is the shape of a `ClusterCleanupPolicy`. Read it, but do not apply it: the cleanup controller in this playground has no permission to delete Deployments yet.

```yaml
apiVersion: kyverno.io/v2
kind: ClusterCleanupPolicy
metadata:
  name: clean-scaled-down-deployments
spec:
  match:
    any:
      - resources:
          kinds:
            - Deployment
          selector:
            matchLabels:
              canremove: "true"
  conditions:
    any:
      - key: "{{ target.spec.replicas }}"
        operator: LessThan
        value: 2
  schedule: "*/5 * * * *"
```

The `match` block picks Deployments with the label `canremove: "true"`. The optional `conditions` block narrows the list again, using the field values of the object, which are named `target`. The `schedule` runs the check every five minutes. A cleanup policy works on objects that already exist, so there is no requesting user to match. That means `match` cannot use `subjects`, `roles` or `clusterRoles`.

## See it in your playground

<!-- astrona:playground:renew -->

Ask the registry desk what the form accepts:

```sh
kubectl explain clustercleanuppolicy.spec
```

Look for the fields `match`, `exclude`, `conditions`, `schedule` and `deletionPropagationPolicy`. Then read which versions the cluster serves:

```sh
kubectl get crd clustercleanuppolicies.kyverno.io -o jsonpath='{.spec.versions[*].name}'
```

Newer Kyverno releases mark the cleanup forms as deprecated and add a `DeletingPolicy` form in the `policies.kyverno.io` API group. The playground runs v1.13.2, where the cleanup forms are the normal way. Check the release you run before you build new automation on them.

## Global context entries: a shared star chart

Without a shared chart, every rule that needs a list of, say, all Deployments asks the registry desk itself, on every request. A `GlobalContextEntry` asks once and caches the answer. A rule then reads the cached copy. It has two possible sources: `kubernetesResource` (a watched list of objects) or `apiCall` (a call to an address).

Read the form on your cluster:

```sh
kubectl explain globalcontextentry.spec
```

You should see `kubernetesResource`, `apiCall` and a `projections` list that picks out values from the cached data. The form is cluster-scoped and has the short name `gctxentry`. On v1.13.2 the version is `v2alpha1`, which means it is still an early version: read the served version with `kubectl get crd globalcontextentries.kyverno.io -o jsonpath='{.spec.versions[*].name}'` before you write one.

## Common pitfalls

> [!WARNING]
> - **Writing a cleanup policy and expecting deletions.** The cleanup controller needs permission to delete the kind you match. Without it, nothing is removed.
> - **A schedule in the wrong format.** `schedule` is a five-field cron expression such as `*/5 * * * *`. A text like `every 5 minutes` is not accepted.
> - **Using `subjects` in a cleanup `match`.** There is no requesting user, so those fields do not apply.
> - **Treating `v2alpha1` as stable.** An alpha version can change between releases.
