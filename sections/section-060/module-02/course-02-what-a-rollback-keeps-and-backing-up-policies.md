# What a Rollback Keeps, and Backing Up Policies

A rollback is a refit in reverse. Some parts of the station return to the old design, and some parts do not move at all. This part sorts the two groups, then shows how to keep your rule books as YAML files you can restore.

The steps below need a healthy release. If `kubectl get pods -n kyverno` still shows an image pull error, roll back first with `helm rollback kyverno 1 -n kyverno --wait`.

## What a rollback changes and what it keeps

Helm rolls back only what the release owns. The release owns the Deployments, the services, the settings and the custom resource definitions (CRDs), which are the new kinds of forms the registry desk accepts. It does not own the objects people create from those forms.

| Object | What a rollback does |
| --- | --- |
| Controller Deployments and their images | Put back as they were in the chosen revision |
| CRDs such as `clusterpolicies.kyverno.io` | Put back as the chosen revision defined them, because the chart ships them as templates |
| `ClusterPolicy`, `Policy` and `PolicyException` objects | Not touched, because they are not in the release |
| Hooks | Only hooks marked for a rollback run. This chart's `kyverno-migrate-resources` Job is a post-upgrade hook, so it does not run on a rollback |

The second row needs care. If the newer CRD added a field and you used it, the older CRD does not know that field. The field can be lost the next time that object is written. So before you roll back across a version that changed policy fields, read the release notes for those versions.

### See it in your playground

<!-- astrona:playground:renew -->

Confirm that the policy is not part of the release. The first command lists the objects Helm manages, and the second looks for your policy in that list:

```sh
helm get manifest kyverno -n kyverno | grep -c "require-cost-center-label"
kubectl get clusterpolicy require-cost-center-label
```

The count is 0, because the policy is not in the release, while the second command shows that it exists. That is why a rollback leaves it alone.

## Back up policies and exceptions

A backup is a copy of your rule books and waivers in your own hands. A `PolicyException` is a signed waiver that lets one named ship skip one rule. Save the policies and the exceptions to files:

```sh
kubectl get clusterpolicies.kyverno.io,policies.kyverno.io -A -o yaml > policy-backup.yaml
kubectl get policyexceptions.kyverno.io -A -o yaml > exception-backup.yaml
```

Use the full names, so there is no doubt which kind each name means when a cluster has several policy kinds. The exception file may hold an empty list in your playground, because no exception exists yet.

### Restore a policy from the backup

A dump from the cluster is a copy for reading and comparing. The API server adds fields to every object that it refuses on a new object. To see this, delete the policy and try to create it from the backup:

```sh
kubectl delete clusterpolicy require-cost-center-label
kubectl create -f policy-backup.yaml
```

The API server refuses the file and mentions `resourceVersion`. Open `policy-backup.yaml` and remove these lines from the policy: `resourceVersion`, `uid`, `creationTimestamp`, `generation`, the whole `managedFields` block and the whole `status` block. Then create it again:

```sh
kubectl create -f policy-backup.yaml
kubectl get clusterpolicy require-cost-center-label
```

The policy is back. The best restore source is still the original policy file in your own source repository, because it has none of these extra fields. The backup from the cluster is your proof of what was running.

> [!TIP]
> Save a backup of every `ClusterPolicy`, `Policy` and `PolicyException` before an upgrade, and name the file with the date. The file is cheap and it ends arguments about what the cluster held.

## Common pitfalls

> [!WARNING]
> - **Thinking a rollback restores policies.** It does not touch them. If a policy changed, you restore it yourself from a file.
> - **Rolling back across a CRD change without reading the notes.** The older CRD can drop fields that only the newer one knew.
> - **Applying a raw dump to a cluster.** Remove `resourceVersion`, `uid`, `creationTimestamp`, `generation`, `managedFields` and `status` first.
> - **Backing up only `ClusterPolicy`.** Namespaced `Policy` objects and `PolicyException` objects need their own copy.
