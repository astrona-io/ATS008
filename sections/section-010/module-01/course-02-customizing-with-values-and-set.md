# Customizing the Install: values.yaml & --set

Astronaut, a baseline `helm install` gives you a working Kyverno. The chart's `values.yaml` is where you really shape it: how many replicas each controller runs, how much CPU and memory they ask for, whether Helm manages the custom resource definitions, and many other settings.

Think of `values.yaml` as the order form for the station kit. You can change it in two ways. A `--set key=value` flag is a single change written on the form. A `-f values.yaml` file is a whole filled-in form of your own.

## Who installs the custom resource definitions: `crds.install`

One value decides whether Helm installs Kyverno's custom resource definitions at all:

```yaml
crds:
  install: true   # default
```

Kyverno ships its custom resource definitions as a separate chart inside the main chart (a chart dependency), switched on by this one setting. Leave it `true`, the default, and Helm installs them and keeps them up to date on every `helm upgrade`. Set it to `false` only if another tool in your pipeline already manages Kyverno's custom resource definitions.

## Sizing the admission controller

The admission controller is the team of inspectors at the launch gate. Two settings for it matter most from day to day:

```yaml
admissionController:
  replicas: 2

  container:
    resources:
      requests:
        cpu: 100m
        memory: 128Mi
      limits:
        memory: 384Mi
```

Look closely at the nesting. `replicas` sits directly under `admissionController`. `resources` sits one level deeper, under `admissionController.container`. You will meet this same extra `container` level again when you set controller flags, so learn to look for it now.

The other three controllers each have their own on and off switch:

```yaml
backgroundController:
  enabled: true   # default

reportsController:
  enabled: true   # default

cleanupController:
  enabled: true   # default
```

Setting one of them to `false` removes that controller's Deployment from the install completely.

## `--set` flags or a values file

You now know which keys to change. Here are the two ways to hand them to Helm.

### A few changes: `--set`

For one or two changes, `--set` on the command line is fine:

```sh
helm install kyverno kyverno/kyverno -n kyverno --create-namespace \
  --set admissionController.replicas=2 \
  --set admissionController.container.resources.requests.cpu=100m \
  --set admissionController.container.resources.requests.memory=128Mi
```

Each `--set` uses dots to walk down the same nesting you saw in the YAML above.

### More changes: a values file

For anything bigger, a values file is easier to read, review and keep in version control.

Save this as `values.yaml`:

```yaml
admissionController:
  replicas: 2
  container:
    resources:
      requests:
        cpu: 100m
        memory: 128Mi
```

Install with it:

```sh
helm install kyverno kyverno/kyverno -n kyverno --create-namespace -f values.yaml
```

Then check the result on the live Deployment, not just in Helm:

```sh
kubectl get deploy kyverno-admission-controller -n kyverno -o yaml
```

Look for `replicas: 2` under `spec`, and for `cpu: 100m` and `memory: 128Mi` under the container's `resources.requests`. That is the Kubernetes Deployment itself telling you what it runs.

> [!TIP]
> Before you write your own values, run `helm show values kyverno/kyverno`. It prints the chart's full default `values.yaml`, so you can copy the exact key path instead of guessing it.

## Common pitfalls

> [!WARNING]
> - **Putting `resources` directly under `admissionController`.** The key is `admissionController.container.resources`. A wrong path does not cause an error; Helm just ignores it.
> - **Mixing up `requests` and `limits`.** A request is what the pod is promised; a limit is the most it may use. Graders and schedulers read them separately.
> - **Trusting the command instead of the cluster.** Read the values back from the live Deployment to prove they landed.

## Your mission: Helm Install with Custom Values

You can now install Kyverno into its own namespace and size the admission controller with `--set` or a values file. The mission asks you to do exactly that on a fresh cluster: install release `kyverno`, set two replicas and the resource requests, and confirm the release.

Start the mission:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS008.git -c sections/section-010/module-01/labs/lab-01
```

Read the task in [`question.md`](./labs/lab-01/question.md) and solve it on your own first. When you think you are done, send it for grading:

```sh
astrona submit -c sections/section-010/module-01/labs/lab-01
```

When the mission is done, remove it:

```sh
astrona destroy ats-008-lab-001
```
