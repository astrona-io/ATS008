# Part 1 — Adding the Repo & a Baseline Install

> Prerequisite: [Landing page](./course.md). Next: [Part 2 — Customizing the Install: values.yaml & --set](./course-02-customizing-with-values-and-set.md).

## Adding the repo

Helm charts live in repositories, and Kyverno publishes its own. Before you can install anything, add it and refresh Helm's local index:

```sh
helm repo add kyverno https://kyverno.github.io/kyverno/
helm repo update
```

`helm repo add` just registers the URL under the local name `kyverno` — it downloads nothing yet. `helm repo update` pulls the current chart index so `helm install kyverno/kyverno` resolves to the latest chart version Helm knows about.

## The dedicated-namespace rule

Kyverno's own documentation is explicit on this point: Kyverno **must always be installed in a dedicated Namespace** and **must not be co-located with other applications**. This is not just tidiness — Kyverno's admission webhook intercepts writes across the cluster, and keeping its own controllers, ServiceAccounts, and RBAC isolated in one namespace makes it far easier to reason about (and lock down) exactly what has access to that machinery.

By convention, that namespace is called `kyverno`.

## A baseline install

```sh
helm install kyverno kyverno/kyverno -n kyverno --create-namespace
```

Reading this command:

- `kyverno` (first positional argument) is the **release name** — Helm's label for "this particular installation," used by every later `helm upgrade`/`helm status`/`helm uninstall` call.
- `kyverno/kyverno` is `<repo-name>/<chart-name>` — the chart you added above.
- `-n kyverno --create-namespace` creates and targets the dedicated namespace from the rule above.

This is a fine baseline for a scratch or learning cluster. For a production, highly-available install, Kyverno's docs give a more deliberate example (covered in full in Section 050):

```sh
helm install kyverno kyverno/kyverno -n kyverno --create-namespace \
  --set admissionController.replicas=3 \
  --set backgroundController.replicas=2 \
  --set cleanupController.replicas=2 \
  --set reportsController.replicas=2
```

## Verifying the install

Three commands tell you almost everything you need to know right after installing:

```sh
kubectl get pods -n kyverno
kubectl get crd | grep kyverno.io
helm list -n kyverno
```

- `kubectl get pods -n kyverno` should show one pod per controller (admission, background, cleanup, reports) in `Running` state.
- `kubectl get crd | grep kyverno.io` confirms Kyverno's Custom Resource Definitions actually landed (more on the full CRD surface in Section 020).
- `helm list -n kyverno` shows the release itself, with a `STATUS` column that should read `deployed`.

> [!TIP]
> **Try it — confirm the release status in detail**
>
> ```sh
> helm status kyverno -n kyverno
> ```
>
> This prints the same `STATUS: deployed` line `helm list` summarizes, plus the exact `REVISION` number (you'll use this in Section 060 when upgrading) and any post-install notes the chart defines.

## Reference

- `helm show chart kyverno/kyverno` — metadata about the chart itself (maintainers, version) without installing anything.
- Kyverno's installation documentation for the full list of supported install methods (Helm is the recommended one; a plain-manifest alternative exists but cannot be upgraded in place — see Section 060).

> [!WARNING]
> **Common pitfall**
>
> Installing Kyverno with `-n kube-system` or into any namespace already hosting other workloads. This violates the dedicated-namespace rule directly: Kyverno's RBAC, its webhook TLS secrets, and its own admission-exempt status all assume it is the only tenant of that namespace. Sharing it with unrelated applications makes future RBAC scoping (Section 040) and namespace-level cleanup far riskier than it needs to be.
