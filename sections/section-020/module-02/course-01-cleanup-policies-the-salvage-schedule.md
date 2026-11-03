# Cleanup Policies: The Salvage Schedule

A cleanup policy is a salvage schedule. It says which objects to remove and when. There are two kinds: a `CleanupPolicy` is a schedule for one planet (a namespace), and a `ClusterCleanupPolicy` is a schedule for the whole solar system. The cleanup controller, the salvage crew, reads them and does the deleting.

## The shape of a schedule

Both kinds use `apiVersion: kyverno.io/v2`. Two fields are required: `match` and `schedule`. These are the fields the chart's CRDs have:

| Field | What it does |
| --- | --- |
| `match` | Picks the objects to consider, with `any` or `all` and a `resources` block |
| `exclude` | Removes objects from the match, in the same shape as `match` |
| `conditions` | Narrows the list again by testing fields of each object |
| `schedule` | A cron expression that says when the crew runs |
| `deletionPropagationPolicy` | `Foreground`, `Background` or `Orphan`: how deletes cascade |
| `context` | Extra data the conditions can use |

A `CleanupPolicy` only acts on objects in its own planet. A `ClusterCleanupPolicy` acts on any planet, so add `namespaces` in `match` if you want to limit it.

## See it in your playground

First look at what the cleanup controller is and what the cluster knows about the form:

<!-- astrona:playground:renew -->

```sh
kubectl get deployment kyverno-cleanup-controller -n kyverno
kubectl get crd cleanuppolicies.kyverno.io -o jsonpath='{.spec.versions[*].name}'
```

The Deployment should be ready. The second command prints the served versions. The `v2` version is the one to write. The chart marks the cleanup versions as deprecated: a newer form, `DeletingPolicy`, exists next to them. The cleanup forms still work on this release.

Read the fields from the cluster itself:

```sh
kubectl explain cleanuppolicy.spec
```

Look for `match`, `exclude`, `conditions`, `schedule` and `deletionPropagationPolicy`. Then check that no schedule exists yet:

```sh
kubectl get cleanuppolicy -A
```

It should report that no resources were found. The short names are `cleanpol` and `ccleanpol`.

## Match, exclude and conditions

`match` and `exclude` pick objects by `kinds`, `names`, `namespaces`, `selector` (labels) and more. Because a cleanup policy works on objects that already exist, there is no requesting user. That means `match` cannot use `subjects`, `roles` or `clusterRoles`.

`conditions` test a field of each object. Inside a condition, the candidate object is called `target`. For example `{{ target.metadata.labels.scrap }}` reads the `scrap` label. If the conditions are true, the object is deleted. The shape is the same `any` and `all` lists that `deny` rules use.

Here is a policy that deletes labelled ConfigMaps only when a second label also says so. Only read it for now. The salvage crew has no permission to delete ConfigMaps yet:

```yaml
apiVersion: kyverno.io/v2
kind: CleanupPolicy
metadata:
  name: remove-expired-scrap
  namespace: docking-bay
spec:
  match:
    any:
      - resources:
          kinds:
            - ConfigMap
          selector:
            matchLabels:
              scrap: "true"
  conditions:
    any:
      - key: "{{ target.metadata.labels.expired }}"
        operator: Equals
        value: "yes"
  schedule: "*/5 * * * *"
```

The `match` picks scrap ConfigMaps and the `conditions` keep only those with `expired: "yes"`. The crew runs the check every five minutes.

## Reading a cron schedule

The five fields are minute, hour, day of month, month and day of week. A star means "every". So `* * * * *` runs every minute, `*/5 * * * *` runs every five minutes and `0 3 * * *` runs at three o'clock every night. A schedule never runs more often than once a minute.

## Common pitfalls

> [!WARNING]
> - **Using `CleanupPolicy` and expecting it to reach other planets.** It only sees its own namespace. Use `ClusterCleanupPolicy` for more.
> - **Using `subjects` or `roles` in `match`.** They do not apply to cleanup, because there is no requesting user.
> - **A wrong `schedule`.** It must be a five-field cron expression. A long interval means a long wait before the first deletion.
> - **Writing `{{ request.object... }}` in a condition.** There is no admission request. Use `target`.
