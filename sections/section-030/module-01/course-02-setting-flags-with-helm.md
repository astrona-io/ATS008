# Setting Flags with Helm

You never fix a flag by editing a Deployment with `kubectl edit`. The next `helm upgrade` would overwrite your change without a word. The supported way is the order form: you write the flag into the Helm values, and Helm updates the Deployment for you.

## The extraArgs map

Every crew has an `extraArgs` value. It is a map: each key is a flag name without the dashes, and each value is the flag value. The chart turns `genWorkers: 5` into `--genWorkers=5`.

The path to `extraArgs` is not the same for every crew:

| Controller | Values path |
| --- | --- |
| Admission | `admissionController.container.extraArgs` |
| Background | `backgroundController.extraArgs` |
| Reports | `reportsController.extraArgs` |
| Cleanup | `cleanupController.extraArgs` |

Only the admission controller has `container` in its path. If you write `admissionController.extraArgs`, Helm does not complain. The key simply sits where no template reads it, and the flag never reaches the Pod.

### Check the result before you apply it

`helm template` renders the manifests on your laptop and does not touch the cluster. It is the cheapest way to see where a flag lands. Run it with the flag you plan to set, and look for it in the output.

<!-- astrona:playground:renew -->

### See it in your playground

Render the chart with `--genWorkers=5` on the background controller and search for the flag:

```sh
helm template kyverno kyverno/kyverno -n kyverno \
  --set backgroundController.extraArgs.genWorkers=5 | grep -n "genWorkers"
```

You should see exactly one line with `--genWorkers=5`. Now make the mistake on purpose and set it on the admission controller without `container`:

```sh
helm template kyverno kyverno/kyverno -n kyverno \
  --set admissionController.extraArgs.webhookTimeout=15 | grep -n "webhookTimeout"
```

This prints nothing. The flag fell into a place that no template reads. With the right path, `admissionController.container.extraArgs.webhookTimeout=15`, the same search finds `--webhookTimeout=15`.

## Apply a flag with helm upgrade

`helm upgrade --reuse-values` keeps every value you set earlier and adds the new one. Each upgrade adds a new revision to the flight record, and the crew's Deployment rolls out new Pods with the new flag.

Set the background controller's `--genWorkers`:

```sh
helm upgrade --reuse-values -n kyverno kyverno kyverno/kyverno \
  --set backgroundController.extraArgs.genWorkers=5
```

Wait for the new Pods, then read the live flags back. Do not trust the exit code of `helm upgrade` alone:

```sh
kubectl rollout status deployment/kyverno-background-controller -n kyverno --timeout=120s
kubectl get deploy kyverno-background-controller -n kyverno \
  -o jsonpath='{range .spec.template.spec.containers[0].args[*]}{@}{"\n"}{end}'
```

The list now ends with `--genWorkers=5`. The other three crews did not roll out, because their values did not change.

### What the chart already set

Some flags are set by the chart and by you. The reports controller starts with `--backgroundScanInterval=1h` from the chart. When you add `backgroundScanInterval: 30m` to its `extraArgs`, the live list holds both lines, and the one that comes later wins. Your `extraArgs` flags come last, so they win over the chart's own. Read the full list to see both.

### Several changes in one file

For more than one flag, a values file is easier to read than a long chain of `--set`. Save this as `controller-flags-values.yaml`:

```yaml
reportsController:
  extraArgs:
    backgroundScanInterval: 30m

cleanupController:
  extraArgs:
    ttlReconciliationInterval: 5m
```

Apply it:

```sh
helm upgrade --reuse-values -n kyverno kyverno kyverno/kyverno -f controller-flags-values.yaml
```

Then check the result. This time ask Helm what it knows, and compare it to the cluster:

```sh
helm get values kyverno -n kyverno
```

The output lists everything you set so far, including `genWorkers`. It is the order form as you filled it in. The Deployment `args` are what actually runs.

## Flags and the ConfigMap are different dials

Not every Kyverno setting is a flag. Settings such as `config.excludeGroups` and `config.resourceFilters` sit in the Kyverno ConfigMap, the station notice board. The crews watch that board and read changes live, without a restart. A flag, by contrast, is read once when the program starts. So a flag change always rolls out new Pods, and a ConfigMap change does not.

When you plan a change, ask first: is it under a crew's `extraArgs`, or under `config`? That tells you whether to expect a rollout.

## Common pitfalls

> [!WARNING]
> - **Writing `extraArgs` as a list.** With this chart, `extraArgs[0]=--genWorkers=5` renders as `--0=--genWorkers=5`. Use the map form, `extraArgs.genWorkers=5`, and leave out the dashes.
> - **Dropping `container` for the admission controller.** The path is `admissionController.container.extraArgs`. A wrong path raises no error.
> - **Forgetting `--reuse-values`.** Without it, `helm upgrade` goes back to the chart defaults for every value you did not repeat, and earlier flags disappear.
> - **Patching the Deployment by hand.** The next `helm upgrade` replaces your patch.
> - **Calling the job done when Helm says `deployed`.** Read the live `args` and wait for the rollout.

## Your mission: Controller Flag Tuning Lab

You can now set a flag on one crew with Helm and prove that it reached the right Deployment. The mission starts a fresh cluster with Kyverno at default values. It asks you to set `--genWorkers=5` on the background controller and `--backgroundScanInterval=30m` on the reports controller, then confirm both in the live Deployments.

Pause the playground first, so the lab has the memory it needs:

```sh
astrona stop ats-008-playground-030-01
```

Start the lab, then grade it when you are done:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS008.git -c sections/section-030/module-01/labs/lab-01
astrona submit -c sections/section-030/module-01/labs/lab-01
```

When you are done, remove the lab and start the playground again:

```sh
astrona destroy ats-008-lab-005
astrona start ats-008-playground-030-01
```
