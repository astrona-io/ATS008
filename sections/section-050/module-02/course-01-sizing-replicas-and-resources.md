# Sizing Replicas and Resources

Every Kyverno controller is a Deployment, and the chart has a replica key and a resource key for each. This part shows where they are, what the chart sets for you, and what Kyverno's scaling guidance says about choosing numbers.

## Where the keys are

Kyverno's scaling guidance says it supports multiple replicas for each of its controllers, but the effect differs per controller. The chart has one block per controller. Resource keys sit at a slightly different depth for the admission controller.

| Controller | Replicas | Resources |
| --- | --- | --- |
| Admission | `admissionController.replicas` | `admissionController.container.resources` |
| Background | `backgroundController.replicas` | `backgroundController.resources` |
| Reports | `reportsController.replicas` | `reportsController.resources` |
| Cleanup | `cleanupController.replicas` | `cleanupController.resources` |

The admission controller also has an `initContainer` with its own `resources`. That container runs once at start-up and is not the one that answers calls.

## What the chart sets by default

The chart leaves every `replicas` value empty, so Kubernetes runs one ship per Deployment. It rejects `replicas: 0`. The defaults for resources, read from `helm show values kyverno/kyverno`, are these:

| Controller container | Requests | Limits |
| --- | --- | --- |
| Admission (`container`) | `cpu: 100m`, `memory: 128Mi` | `memory: 384Mi` |
| Background | `cpu: 100m`, `memory: 64Mi` | `memory: 128Mi` |
| Reports | `cpu: 100m`, `memory: 64Mi` | `memory: 128Mi` |
| Cleanup | `cpu: 100m`, `memory: 64Mi` | `memory: 128Mi` |

A **request** is the amount of fuel the scheduler reserves for a ship. A **limit** is the most it may burn. The defaults have no CPU limit at all, only a memory limit. That matches Kyverno's guidance, which says it recommends not setting CPU limits and testing in your own environment to find real use.

The admission controller can also use a HorizontalPodAutoscaler. `admissionController.autoscaling.enabled` is `false` by default, and the chart then sets the replica count itself. When you turn autoscaling on, the chart leaves `replicas` out of the Deployment so the autoscaler can own it. The defaults under that key are `minReplicas: 1`, `maxReplicas: 10` and `targetCPUUtilizationPercentage: 80`.

## Choosing numbers

Kyverno's guidance is short, and this course does not add numbers to it. It says admission replicas share the AdmissionReview load and do not split the policy set. It says to size the admission controller's memory for the number of policies in the cluster, and to add replicas for webhook throughput and availability. Measure your own cluster, then change the values.

## See it in your playground

Read what the starting cluster runs. Kyverno was installed at default values, so you should see one replica each and the requests from the table above:

<!-- astrona:playground:renew -->

```sh
kubectl get deploy -n kyverno -o custom-columns=NAME:.metadata.name,REPLICAS:.spec.replicas,REQ_CPU:.spec.template.spec.containers[0].resources.requests.cpu,REQ_MEM:.spec.template.spec.containers[0].resources.requests.memory
```

Now resize the admission controller. Save this as `admission-sizing-values.yaml`:

```yaml
admissionController:
  replicas: 3
  container:
    resources:
      requests:
        cpu: 200m
        memory: 256Mi
      limits:
        memory: 512Mi
```

These numbers are an example for practice, not a recommendation. Apply it:

```sh
helm upgrade kyverno kyverno/kyverno -n kyverno -f admission-sizing-values.yaml
```

Then check the result. Wait for the rollout and read the live Deployment:

```sh
kubectl -n kyverno rollout status deployment/kyverno-admission-controller --timeout=180s
kubectl get deploy kyverno-admission-controller -n kyverno -o jsonpath='{.spec.replicas}{"  "}{.spec.template.spec.containers[0].resources}{"\n"}'
```

The first number is `3`, and the resources show the requests and the memory limit from your file. Because you used `-f` without `--reuse-values`, any earlier `--set` values would have been dropped. In this playground there were none.

Last, compare with what the chart would render:

```sh
helm get values kyverno -n kyverno
```

Only your file's values appear. Add `-a` to see every default too.

## Common pitfalls

> [!WARNING]
> - **Looking for the admission resources in the wrong place.** They are under `admissionController.container.resources`. Setting `admissionController.resources` does nothing for the container that answers calls.
> - **Adding a CPU limit by habit.** The chart sets none, and Kyverno recommends not setting one.
> - **Scaling the background or reports controller for speed.** Only the lease holder works. Extra replicas add failover only.
> - **Forgetting that `helm upgrade -f` replaces earlier `--set` values.** Use `--reuse-values` or put every value in the file.
