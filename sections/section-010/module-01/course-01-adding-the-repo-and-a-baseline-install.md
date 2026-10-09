# Adding the Repo & a Baseline Install

Astronaut, before you can inspect a single launch request, the inspection authority has to be built. In Kubernetes terms: Kyverno has to be installed. This part takes you from an empty cluster to a running Kyverno with four commands, and shows you how to check that it really worked.

## Adding the Helm repository

A Helm chart is a station kit: every part, plus the plan for putting them together. Charts live in a Helm repository, the kit depot you order kits from. Kyverno publishes its own depot, so you add it first and then refresh Helm's local list of kits:

```sh
helm repo add kyverno https://kyverno.github.io/kyverno/
helm repo update
```

`helm repo add` only saves the address under the local name `kyverno`. It downloads nothing yet. `helm repo update` fetches the current list of chart versions, so that `kyverno/kyverno` points at the newest chart Helm knows about.

If you want to read about the chart before you install it, `helm show chart kyverno/kyverno` prints its name, version and maintainers without installing anything.

## The dedicated-namespace rule

Kyverno's own documentation is strict about where it lives. Kyverno **must be installed in a dedicated namespace**, and it **must not share that namespace with other applications**. Think of the namespace as Kyverno's own planet, where nothing else is parked.

This is not just tidiness. Kyverno's admission webhook is the call line that the Kubernetes API server (mission control's registry desk) uses to ask Kyverno about writes all over the cluster. Keeping Kyverno's controllers, service accounts and permissions alone on one planet makes it much easier to see, and lock down, who can touch that machinery.

By convention, that namespace is called `kyverno`.

## A baseline install

Here is the smallest correct install:

```sh
helm install kyverno kyverno/kyverno -n kyverno --create-namespace
```

Read it piece by piece:

- `kyverno`, the first word after `install`, is the **release name**. A release is one assembled station with its own name and flight record. Every later `helm upgrade`, `helm status` or `helm uninstall` uses this name.
- `kyverno/kyverno` is `<repository name>/<chart name>`: the chart you just added.
- `-n kyverno --create-namespace` creates the dedicated namespace and installs into it.

This is fine for a learning cluster. For a production cluster that must stay up, Kyverno's documentation gives a larger example with more copies (replicas) of each controller:

```sh
helm install kyverno kyverno/kyverno -n kyverno --create-namespace \
  --set admissionController.replicas=3 \
  --set backgroundController.replicas=2 \
  --set cleanupController.replicas=2 \
  --set reportsController.replicas=2
```

The admission controller gets three replicas because every copy can answer requests. The other three controllers get two, so a standby is ready if one copy stops.

## Checking the install

A finished install is not the same as a working one. Three commands tell you almost everything right after installing.

### Try it on your cluster

Run these three checks:

```sh
kubectl get pods -n kyverno
kubectl get crd | grep kyverno.io
helm list -n kyverno
```

Here is what each one should show:

- `kubectl get pods -n kyverno` lists one pod per controller (admission, background, cleanup and reports), each `Running`.
- `kubectl get crd | grep kyverno.io` lists Kyverno's custom resource definitions. A custom resource definition (CRD) teaches mission control's registry a new kind of form, such as `ClusterPolicy`. If none are listed, Kyverno has nothing to read its policies from.
- `helm list -n kyverno` shows the release itself. Its `STATUS` column should say `deployed`.

For more detail on one release, ask Helm directly:

```sh
helm status kyverno -n kyverno
```

This prints the same `STATUS: deployed` that `helm list` sums up, plus the `REVISION` number and any notes the chart prints after an install. Each install or upgrade adds one revision to the release's flight record, so a fresh install shows revision `1`.

> [!TIP]
> After any install, check all three layers: the pods, the custom resource definitions and the Helm release. A release can say `deployed` while a pod is still failing to start.

Helm is the recommended way to install Kyverno. A plain manifest (`install.yaml`) also exists, but it creates no Helm release, so it cannot be upgraded in place later. That is why this course uses Helm.

## Common pitfalls

> [!WARNING]
> - **Installing Kyverno into `kube-system` or a namespace that already runs other workloads.** This breaks the dedicated-namespace rule. Kyverno's permissions, its webhook certificates and its own exemption from checks all assume it is alone on its planet. Sharing it makes later permission changes and namespace cleanup much riskier.
> - **Forgetting `--create-namespace`.** Without it, the install fails if the `kyverno` namespace does not exist yet.
> - **Stopping at `helm list`.** `deployed` means Helm finished. It does not mean every pod is running or every custom resource definition is present. Check all three.
