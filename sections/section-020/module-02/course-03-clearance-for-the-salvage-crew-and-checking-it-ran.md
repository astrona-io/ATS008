# Clearance for the Salvage Crew and Checking That It Ran

A salvage schedule only works if the crew has clearance. The cleanup controller runs with its own service account, the crew's registration papers, and by default those papers do not allow deleting your ConfigMaps. This part shows you how to give it clearance, run a real policy, and prove from three sources that the crew ran.

## Whose permissions count

Which part does the work? The cleanup controller, in the Deployment `kyverno-cleanup-controller`, with the service account `kyverno-cleanup-controller`. Its default clearance lets it read policies and manage its own webhook. It does not let it delete ConfigMaps, Pods or Deployments. You add clearance with a `ClusterRole` that has the label `rbac.kyverno.io/aggregate-to-cleanup-controller: "true"`. The master card `kyverno:cleanup-controller` collects every card with that stamp. The chart value `cleanupController.clusterRole.extraResources` adds rules at install time.

## See it in your playground

Ask the clearance office first:

<!-- astrona:playground:renew -->

```sh
kubectl auth can-i delete configmaps -n docking-bay --as=system:serviceaccount:kyverno:kyverno-cleanup-controller
```

The answer should be `no`. Save this as `clusterrole-cleanup-configmaps.yaml`:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: cleanup-configmaps
  labels:
    rbac.kyverno.io/aggregate-to-cleanup-controller: "true"
rules:
  - apiGroups:
      - ""
    resources:
      - configmaps
    verbs:
      - get
      - list
      - watch
      - delete
```

Apply it:

```sh
kubectl apply -f clusterrole-cleanup-configmaps.yaml
```

Then check again. Kubernetes folds the new card into the master card within a few seconds, so run it again if the answer is still `no`:

```sh
kubectl auth can-i delete configmaps -n docking-bay --as=system:serviceaccount:kyverno:kyverno-cleanup-controller
```

## Write the salvage schedule

Save this as `cleanuppolicy-remove-scrap.yaml`. It deletes every ConfigMap with the label `scrap: "true"` in `docking-bay`, every minute:

```yaml
apiVersion: kyverno.io/v2
kind: CleanupPolicy
metadata:
  name: remove-scrap
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
  schedule: "* * * * *"
```

Apply it:

```sh
kubectl apply -f cleanuppolicy-remove-scrap.yaml
```

Kyverno checks a cleanup policy when you apply it, so a policy for a kind that the crew may not delete can be refused. Read the message if the apply fails.

## Check that it ran

Wait a little over a minute. Then look at three sources. First, the objects themselves:

```sh
kubectl get configmap -n docking-bay --show-labels
```

`old-scrap` should be gone and `keep-me` should remain. Second, the policy status records the last time the crew ran it:

```sh
kubectl get cleanuppolicy remove-scrap -n docking-bay -o jsonpath='{.status.lastExecutionTime}'
```

A time stamp means the crew has run the schedule at least once. Third, the crew's own log:

```sh
kubectl logs -n kyverno deployment/kyverno-cleanup-controller --tail=30
```

Look for lines that mention the policy or the deleted object. If the object is still there and the status is empty, check the permission first and the schedule second.

## Common pitfalls

> [!WARNING]
> - **Forgetting the label on the `ClusterRole`.** Without `rbac.kyverno.io/aggregate-to-cleanup-controller: "true"`, the card is never added to the crew's master card.
> - **Giving only `delete`.** The crew also needs `list` and `watch` to find objects.
> - **Checking the objects too early.** The first run happens at the next time the schedule matches. With `* * * * *` that is within about a minute.
> - **Granting too much.** A card with `delete` on every resource lets one cleanup policy remove anything. Name only the kinds you need.

## Your mission: Cleanup Policy Lab

You can now give the cleanup controller clearance, write a `CleanupPolicy` and prove that it removed the right object. The mission starts a fresh solar system with a planet called `salvage-yard`, and asks you to grant the crew clearance for ConfigMaps and write a policy that clears the labelled ones every minute, while leaving everything else alone.

Pause your playground first:

```sh
astrona stop ats-008-playground-020-02
```

Start the mission, then grade it when you are done:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS008.git -c sections/section-020/module-02/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS008.git -c sections/section-020/module-02/labs/lab-01
```

When you have finished, remove the mission and bring your playground back:

```sh
astrona destroy ats-008-lab-014
astrona start ats-008-playground-020-02
```
