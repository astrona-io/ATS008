# Overview: Kyverno's RBAC Model (Playground)

This playground is a training solar system with Kyverno already assembled by Helm. There is no grading. You use it to read the clearance cards (ClusterRoles) of the four controllers and to grant one controller a new permission.

## What's in the box

| Item | Detail |
| --- | --- |
| Helm release | `kyverno` in namespace `kyverno`, latest `kyverno/kyverno` chart, default values except one |
| Controllers | `kyverno-admission-controller`, `kyverno-background-controller`, `kyverno-reports-controller`, `kyverno-cleanup-controller` |
| `ClusterPolicy` | `generate-default-quota`: every new namespace should get a `ResourceQuota` named `default-quota` (`pods: "10"`) |
| The one changed value | `backgroundController.rbac.coreClusterRole.extraResources` is `[]`. The chart normally fills it with create, update, patch and delete on kinds such as `resourcequotas`. |

Because of that one value, the background controller can read `ResourceQuota` objects but cannot create them. The `generate-default-quota` rule therefore has nothing to build with until you add a permission.

## Helpers

```sh
can_do() {
  kubectl auth can-i "$1" "$2" --as="system:serviceaccount:kyverno:kyverno-$3-controller"
}
```

Use it as `can_do <verb> <resource> <controller>`, for example `can_do create resourcequotas background`. It prints `yes` or `no`.

## Practice tasks

- List the Kyverno service accounts and the ClusterRoles that carry the label `app.kubernetes.io/part-of=kyverno`.
- Read `kubectl get clusterrole kyverno:background-controller -o yaml` and find the `aggregationRule`.
- Run `can_do` for `create`, `delete` and `list` on `resourcequotas` for each of the four controllers.
- Create a namespace and check whether `default-quota` appears. Look at `kubectl get updaterequest -A` and the events.
- Save and apply a ClusterRole with the label `rbac.kyverno.io/aggregate-to-background-controller: "true"` that allows `get`, `list`, `watch`, `create` and `update` on `resourcequotas`. Run `can_do` again, then create a second namespace.
- Delete your ClusterRole and watch the permission disappear again.
