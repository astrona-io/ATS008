# Summary

Kyverno runs as four controllers, and each one flies under its own service account. Their permissions come from clearance cards (ClusterRoles) that Kubernetes joins together by aggregation.

## What you learned

**ServiceAccounts, Aggregated ClusterRoles and the View Role** ([read it again](./course-01-serviceaccounts-and-aggregated-clusterroles.md)). The four service accounts are `kyverno-admission-controller`, `kyverno-background-controller`, `kyverno-reports-controller` and `kyverno-cleanup-controller`, all in the `kyverno` namespace. Each is bound to a master ClusterRole whose `aggregationRule` collects every ClusterRole with the label `rbac.kyverno.io/aggregate-to-<controller>-controller: "true"`, plus the `:core` card that the chart ships. The admission, background and reports controllers also hold the built-in `view` role, so they can read most built-in objects.

**Granting Extra Permissions Safely** ([read it again](./course-02-granting-extra-permissions-safely.md)). A valid `generate` rule can build nothing because the background controller may not create the target kind. The fix is a new ClusterRole with the right label, never an edit of a shipped role, because `helm upgrade` writes the shipped roles again. `kubectl auth can-i ... --as=system:serviceaccount:kyverno:...` proves the result at once.

Key facts:

- The label ends with the name of the controller that receives the permission.
- `apiGroups: [""]` is the core group. Other kinds need their own group.
- A rule that failed earlier is not replayed. Test with a new namespace.

## Missions

| Mission | Lab name | What you prove |
| --- | --- | --- |
| ClusterRole Aggregation Lab | `ats-008-lab-007` | You grant the background controller `resourcequotas` with a labelled ClusterRole, and a new namespace gets its `default-quota` |

## Check yourself

- Which label would you put on a ClusterRole that the cleanup controller needs?
- Why does editing `kyverno:background-controller:core` not last?
- Which command shows, without waiting, whether a controller may create a kind?

When you finish, clean up the playground. List what is running, then destroy it:

```sh
astrona list
astrona destroy ats-008-playground-040-01
```

<!-- astrona:playground:destroy -->
