# Summary

The four Kyverno crews hold only the clearance cards for their own jobs. When a job needs a card the crew does not hold, the policy is accepted and the work fails. You find the crew, find the kind and the verb, and grant exactly that.

## What you learned

**What Each Controller May Do by Default** ([read it again](./course-01-what-each-controller-may-do-by-default.md)). Each controller has a master ClusterRole (`kyverno:<controller>-controller`) joined from its shipped `:core` card and any ClusterRole with its aggregation label. The admission, background and reports controllers also hold the `view` pass. The cleanup controller has no `delete` on ConfigMaps or workloads, and the reports controller cannot read custom resources through `view`. `kubectl auth can-i --list --as=...` shows the sum.

**When a Controller Lacks a Permission** ([read it again](./course-02-when-a-controller-lacks-a-permission.md)). A cleanup policy needs `list` and `delete` for the cleanup controller, reports for a custom resource need `get`, `list` and `watch` for the reports controller, and mutate-existing and generate rules need write verbs for the background controller. A ClusterRole with the matching `rbac.kyverno.io/aggregate-to-<controller>-controller: "true"` label adds the card at once.

**Chart Values for Permissions and Least Privilege** ([read it again](./course-03-chart-values-for-permissions-and-least-privilege.md)). `<controller>.rbac.clusterRole.extraResources` builds a `kyverno:<controller>-controller:additional` ClusterRole, and `coreClusterRole.extraResources` writes into the `:core` card. A list in a values file replaces the default list. Audit with `can-i '*' '*'`, with the labelled ClusterRoles and with `can-i --list`.

Key facts:

- The label ends with the name of the controller that receives the permission.
- The cleanup controller needs `list` and `delete`, the reports controller `get`, `list` and `watch`.
- Never edit a shipped card. Add a new one.

## Missions

| Mission | Lab name | What you prove |
| --- | --- | --- |
| Cleanup Controller Permissions Lab | `ats-008-lab-018` | You let the cleanup controller delete ConfigMaps with a labelled ClusterRole, a `ClusterCleanupPolicy` removes the expired ones, and the crew has no wider power |

## Check yourself

- A cleanup policy is applied and the objects stay. Which crew, which verb and which kind do you check first?
- Why does a custom resource get no policy report even though the policy is Ready?
- What is the difference between `clusterRole.extraResources` and `coreClusterRole.extraResources`?

When you finish, clean up the playground. List what is running, then destroy it:

```sh
astrona list
astrona destroy ats-008-playground-040-02
```

<!-- astrona:playground:destroy -->
