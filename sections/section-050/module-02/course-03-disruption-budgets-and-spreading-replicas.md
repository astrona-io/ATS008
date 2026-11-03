# Disruption Budgets and Spreading Replicas

This part gives you the three values that decide how Kyverno behaves during a node drain: the PodDisruptionBudget, the spread rules and the priority class. You set them in a values file and prove them on the live objects.

## The PodDisruptionBudget

A **PodDisruptionBudget** (PDB) tells Kubernetes how many ships of one crew may be missing during voluntary evictions such as a drain. Each controller has a `podDisruptionBudget` block with these keys:

| Key | Default | Meaning |
| --- | --- | --- |
| `enabled` | `false` | Turn the budget on |
| `minAvailable` | `1` | At least this many Pods must stay up |
| `maxUnavailable` | empty | At most this many Pods may be missing |
| `unhealthyPodEvictionPolicy` | empty | `IfHealthyBudget` or `AlwaysAllow` |

The chart creates the budget when `enabled` is true or when the controller has more than one replica. That is why a single-replica install has no budget and an HA install has four, as `helm template` shows.

You may set `minAvailable` or `maxUnavailable`, not both. The chart fails with `Cannot set both .minAvailable and .maxUnavailable`. Because `minAvailable` defaults to `1`, switching to `maxUnavailable` means you must also clear the default with `minAvailable: null`.

A budget with `minAvailable: 1` on three replicas lets two Pods go at once. For the admission controller you may want `maxUnavailable: 1`, so a drain removes one at a time.

## Spreading: anti-affinity and topology spread

The chart already adds a soft `podAntiAffinity` to every controller (`preferredDuringSchedulingIgnoredDuringExecution`, topology key `kubernetes.io/hostname`). You can switch it off per controller with `antiAffinity.enabled: false`.

`topologySpreadConstraints` is an empty list by default. Each entry says how evenly the Pods of one crew must be spread over a kind of place. `maxSkew: 1` means the busiest dock may hold at most one ship more than the emptiest. `whenUnsatisfiable` is `DoNotSchedule` (a hard rule) or `ScheduleAnyway` (a preference). The `labelSelector` says which Pods count.

On a real cluster this spreads replicas over nodes, or over zones with the `topology.kubernetes.io/zone` key. On your one-node playground there is a single place, so every Pod lands on it and the rule always holds. You can prove the constraint is on the Deployment. You cannot prove it moved any Pod.

## Priority class

Each controller has `priorityClassName`, and there is a `global.priorityClassName` that applies to all and is overridden by the controller's own value. A **priority class** tells the scheduler which Pods win when the dock is full. Kubernetes ships `system-cluster-critical` for important cluster services. The class must exist in the cluster, or its Pods cannot be created.

## See it in your playground

Raise the admission controller to three replicas with a budget, a spread rule and a priority class. Save this as `admission-disruption-values.yaml`:

<!-- astrona:playground:renew -->

```yaml
admissionController:
  replicas: 3
  priorityClassName: system-cluster-critical
  podDisruptionBudget:
    minAvailable: null
    maxUnavailable: 1
  topologySpreadConstraints:
    - maxSkew: 1
      topologyKey: kubernetes.io/hostname
      whenUnsatisfiable: ScheduleAnyway
      labelSelector:
        matchLabels:
          app.kubernetes.io/component: admission-controller
```

Apply it and wait:

```sh
helm upgrade kyverno kyverno/kyverno -n kyverno --reuse-values -f admission-disruption-values.yaml
kubectl -n kyverno rollout status deployment/kyverno-admission-controller --timeout=180s
```

Then check the live objects. First the budgets:

```sh
kubectl get pdb -n kyverno
```

The admission budget shows `MAX UNAVAILABLE` of `1` and a `MIN AVAILABLE` of `N/A`. Its `ALLOWED DISRUPTIONS` column shows how many Pods a drain may take right now. Then read the spread rule and the priority from the Deployment:

```sh
kubectl get deploy kyverno-admission-controller -n kyverno -o jsonpath='{.spec.template.spec.topologySpreadConstraints}{"\n"}{.spec.template.spec.priorityClassName}{"\n"}'
```

You should see your constraint and `system-cluster-critical`. If a Pod stays `Pending`, the scheduler message in `kubectl describe pod` says why.

Now try the mistake. Set both keys and read the error:

```sh
helm template kyverno kyverno/kyverno -n kyverno --set admissionController.replicas=3 --set admissionController.podDisruptionBudget.maxUnavailable=1
```

Helm stops with `Cannot set both .minAvailable and .maxUnavailable`, because the default `minAvailable: 1` is still there.

## Common pitfalls

> [!WARNING]
> - **Setting `maxUnavailable` and forgetting `minAvailable: null`.** The default `minAvailable: 1` stays, and Helm fails with both set.
> - **Writing `matchLabels` that select nothing.** A spread rule whose selector matches no Pod spreads nothing. Use the component label shown above.
> - **Trusting a spread rule on a one-node cluster.** One place means the rule always holds. It proves the setting, not the spreading.
> - **Naming a priority class that does not exist.** The Pods cannot be created until the class exists.
> - **Using `DoNotSchedule` without enough places.** If the rule cannot be met, Pods stay `Pending`.

## Your mission: Sizing and Spreading Kyverno Lab

You can now set a PodDisruptionBudget, a spread rule and a priority class in a values file and read them from the live objects. The mission starts with Kyverno not installed and asks you to install it with three admission replicas, a budget that allows one disruption, a spread rule and a priority class, plus two background replicas.

Pause the playground first, so the lab has the memory it needs:

```sh
astrona stop ats-008-playground-050-02
```

Start the lab, then grade it when you are done:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS008.git -c sections/section-050/module-02/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS008.git -c sections/section-050/module-02/labs/lab-01
```

When you are done, remove the lab and start the playground again:

```sh
astrona destroy ats-008-lab-019
astrona start ats-008-playground-050-02
```
