# Chart Values for Permissions and Least Privilege

You can give a crew a card in two ways: apply a labelled ClusterRole yourself, or write the rules into the Helm order form. This part shows the chart way, uses it to give the records office its card for a custom resource, and ends with a short audit of what every crew holds. Least privilege means each crew keeps only the cards it needs.

## Two chart values that add rules

Two values add rules for a crew. Both take a list of rules in the same shape as a ClusterRole.

| Value | What the chart builds |
| --- | --- |
| `<controller>.rbac.clusterRole.extraResources` | A new ClusterRole named `kyverno:<controller>-controller:additional`, collected by the master card |
| `<controller>.rbac.coreClusterRole.extraResources` | Extra rules written into the `:core` card itself |

The chart's own comments say the second one exists to avoid breaking old installs, and that new grants belong in `clusterRole.extraResources`. The background controller's `coreClusterRole.extraResources` is not empty by default: it holds the create, update, patch and delete rules for `ingresses`, `ingressclasses`, `networkpolicies`, `roles`, `rolebindings`, `configmaps`, `resourcequotas`, `limitranges` and some resource claims. When you set a list in a values file, the list replaces the default list, it does not add to it.

Which way should you choose? A labelled ClusterRole applies at once and is easy to delete, but it lives outside the release. A chart value is part of the release, so `helm get values` shows it and `helm upgrade --reuse-values` keeps it.

## Give the records office its card

The reports crew must patrol `Beacon` objects, a custom resource. Look first. The playground policy `beacons-need-owner` should produce a report for `beacon-1`.

<!-- astrona:playground:renew -->

### See the missing card

Ask the clearance office, then look for the report:

```sh
can_do list beacons.fleet.example.com reports
kubectl get policyreport -n harbor
```

The answer is `no`, and the report list has no result for `beacon-1`. Look in the reports controller log for a "forbidden" message about `beacons`:

```sh
kubectl logs -n kyverno deployment/kyverno-reports-controller --tail=50
```

### Grant it through the chart

Save this as `values-reports-beacons.yaml`:

```yaml
reportsController:
  rbac:
    clusterRole:
      extraResources:
        - apiGroups:
            - fleet.example.com
          resources:
            - beacons
```

You list the group and the kind only. For the reports controller the chart adds the verbs `get`, `list` and `watch` itself. Apply it to the release, keeping the values you already have:

```sh
helm upgrade kyverno kyverno/kyverno -n kyverno --reuse-values -f values-reports-beacons.yaml
```

Then look for the new card and ask the clearance office again:

```sh
kubectl get clusterrole kyverno:reports-controller:additional
can_do list beacons.fleet.example.com reports
```

The ClusterRole exists and the answer is `yes`. Give the reports crew a minute to pick up the kind, and look at `kubectl get policyreport -n harbor` again. If no result shows after a few minutes, restart the reports controller with `kubectl rollout restart deployment/kyverno-reports-controller -n kyverno` and look again.

## Audit what the crews hold

Least privilege is a habit, not a setting. Check it from time to time.

- Ask each crew about the widest possible power: `kubectl auth can-i '*' '*' --as=system:serviceaccount:kyverno:kyverno-<controller>-controller`. All four answers should be `no`.
- List every ClusterRole that joins a master card by label: `kubectl get clusterrole -l rbac.kyverno.io/aggregate-to-cleanup-controller=true`, and the same for the other three labels. Each card on the list is a grant someone added. Ask who and why.
- Read `kubectl auth can-i --list` for each crew and look for `delete` and `create` on kinds you do not recognise.
- Look at the bindings: `kubectl get clusterrolebinding -o wide` shows which service accounts hold which roles. No Kyverno service account should be bound to `cluster-admin`.

Two more chart values affect clearance. `rbac.roles.aggregate.admin` and `rbac.roles.aggregate.view` (both `true` by default) decide whether Kyverno's report and policy cards are added to the built-in `admin` and `view` roles, so your users can read policies and reports. The `<controller>.rbac.create` and `<controller>.rbac.serviceAccount.name` values let you bring your own roles and service account, which is only for clusters that forbid the chart from creating RBAC objects. If you turn `create` off, you must give the service account name.

## Common pitfalls

> [!WARNING]
> - **Expecting a values list to add to the default list.** A list in a values file replaces the chart's default. Setting `backgroundController.rbac.coreClusterRole.extraResources` to your own rules removes the default grants.
> - **Upgrading without `--reuse-values` or a full values file.** Values you set earlier are lost and the grant disappears.
> - **Writing the grant in `coreClusterRole` out of habit.** The chart says new grants belong in `clusterRole.extraResources`.
> - **Turning off `rbac.create` without a service account name.** The chart refuses to render, because a controller needs a service account.
