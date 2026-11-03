# What Each Controller May Do by Default

Before you grant a crew anything, you need to know what it already holds. In this part you read the four master cards and ask the clearance office what each crew may do. This matters because most permission problems are a gap between a job and a card, and you can only see the gap if you know the card.

## The four default cards

Each controller has a master ClusterRole named `kyverno:<controller>-controller` and a shipped `:core` card that it collects. The most important rules in the chart's cards are these:

| Controller | May write | May read |
| --- | --- | --- |
| Admission | Webhook configurations and admission policies (create, delete) | Its own policies, Secrets and ConfigMaps in the `kyverno` namespace (through a Role), plus the `view` pass |
| Background | Kyverno work orders (`updaterequests`), events, intermediate reports, and the kinds in the chart's default `extraResources` list (for example `ResourceQuota`, `NetworkPolicy`, `Role`, `RoleBinding`) | Policies, namespaces and ConfigMaps, plus the `view` pass |
| Reports | Policy reports and intermediate reports | Policies, namespaces, ConfigMaps, plus the `view` pass |
| Cleanup | Status of cleanup policies, events, the cleanup webhook configuration | Cleanup policies, namespaces and ConfigMaps. No `view` pass |

The last row is the important one for this module. The cleanup controller has no `delete` permission on ConfigMaps, Pods or any workload kind. A cleanup policy can only remove what a card allows it to remove.

The reports controller reads built-in kinds through the `view` pass. That pass does not cover most custom resources, so a custom resource needs its own card.

<!-- astrona:playground:renew -->

### See the cards in your playground

Read the shipped `:core` card of the cleanup controller and look at its rules:

```sh
kubectl get clusterrole kyverno:cleanup-controller:core -o yaml
```

Look for the kinds in `resources` and the verbs next to them. Find `configmaps` with only `get`, `list` and `watch`, and look for any rule that lets the crew delete ConfigMaps. There is none.

### Ask the clearance office

Define the `can_do` helper from the playground guide, then ask whether each crew may delete ConfigMaps:

```sh
can_do delete configmaps admission
can_do delete configmaps background
can_do delete configmaps reports
can_do delete configmaps cleanup
```

You should see four answers of `no`. Then ask for everything one crew may do:

```sh
kubectl auth can-i --list --as=system:serviceaccount:kyverno:kyverno-cleanup-controller
```

The list shows each resource, and the verbs that crew holds on it. Notice how short it is, and how few kinds carry `delete`.

## One chart value per crew

Every controller has the same family of chart values under its own key: `admissionController.rbac`, `backgroundController.rbac`, `reportsController.rbac` and `cleanupController.rbac`. The keys you will meet in this module are `create` (build the roles and bindings), `serviceAccount.name` (use a given service account), `clusterRole.extraResources`, `coreClusterRole.extraResources` and, on three of the controllers, `createViewRoleBinding` and `viewRoleName`. You can list them with `helm show values kyverno/kyverno`.

## Common pitfalls

> [!WARNING]
> - **Assuming the cleanup controller can delete what a policy names.** It may delete only what its cards allow. A cleanup policy for ConfigMaps needs a card with `delete` on `configmaps`.
> - **Assuming the `view` pass covers custom resources.** It covers built-in kinds. A custom resource needs its own labelled ClusterRole.
> - **Reading one master card and calling it the whole picture.** The master card is joined from other cards. Use `kubectl auth can-i --list --as=...` to see the sum.
