# Part 2 — Setting Flags via Helm

> Prerequisite: [Part 1 — The Four Controllers & Their Flags](./course-01-the-four-controllers-and-their-flags.md). Next: [Section 040 — Configuring Kyverno RBAC, Roles, and Permissions](../../section-040/module-01/course.md).

You never edit a controller's flags by hand-patching its Deployment in production — the next `helm upgrade` (or a GitOps reconcile) would silently overwrite the change. The supported path is Helm's per-controller `extraArgs` value.

## extraArgs — and its inconsistent nesting

Every controller accepts extra command-line flags through an `extraArgs` value in `values.yaml`. Where that key lives is **not** the same for every controller, and this is the single most common mistake in this module:

```yaml
admissionController:
  container:
    extraArgs:
      - --webhookTimeout=15

backgroundController:
  extraArgs:
    - --genWorkers=5

reportsController:
  extraArgs:
    - --backgroundScanInterval=30m

cleanupController:
  extraArgs:
    - --ttlReconciliationInterval=5m
```

Notice the asymmetry: `admissionController.container.extraArgs` is nested one level deeper — under `container` — than `backgroundController.extraArgs`, `reportsController.extraArgs`, and `cleanupController.extraArgs`, which sit directly on the controller block. Set `admissionController.extraArgs` (missing `.container.`) and Helm will not error — it will simply create a values key Kyverno's chart templates never read, and your flag never reaches the admission controller's container at all.

## Applying it with helm upgrade

```sh
helm upgrade --reuse-values -n kyverno kyverno kyverno/kyverno \
  --set backgroundController.extraArgs[0]=--genWorkers=5
```

`--reuse-values` carries forward every value from the release's current state, so you only need to specify what's changing. `--set <key>[0]=<value>` is Helm's array-index syntax for setting the first element of a list value.

> [!WARNING]
> **The list-replacement gotcha, again**
>
> Just like `config.excludeGroups` in Section 010, `extraArgs` is a list — a second `helm upgrade` that sets `backgroundController.extraArgs[0]` to a *different* flag **replaces** the whole list, it does not append. If you already set `--genWorkers=5` and later want to add `--v=4` as well, you must set both elements together (`extraArgs[0]` and `extraArgs[1]`), or use a full values file listing everything you want, not just the one new flag.

For multiple changes at once, a values file is clearer than a chain of `--set` flags:

```yaml
# values.yaml
admissionController:
  container:
    extraArgs:
      - --webhookTimeout=15
      - --enablePolicyException=true
      - --exceptionNamespace=capstone-030

cleanupController:
  extraArgs:
    - --ttlReconciliationInterval=5m
```

```sh
helm upgrade --reuse-values -n kyverno kyverno kyverno/kyverno -f values.yaml
```

> [!TIP]
> **Try it — confirm the flag actually landed**
>
> ```sh
> kubectl rollout status deployment/kyverno-background-controller -n kyverno
> kubectl get deploy kyverno-background-controller -n kyverno \
>   -o jsonpath='{.spec.template.spec.containers[0].args}'
> ```
>
> Don't trust that a `helm upgrade` succeeded just because the command exited `0` — always read the live Deployment's `args` back, the same way you did in Part 1.

## ConfigMap settings are a different mechanism

Not every Kyverno setting is a container flag. Values like `config.excludeGroups`, `config.excludeUsernames`, `config.resourceFilters`, and `config.webhooks.namespaceSelector` live in Kyverno's ConfigMap, not in any controller's `args`. Kyverno watches that ConfigMap, and many of these settings are picked up live, without any Pod restarting — a meaningfully different operational story than a flag change, which always requires the Deployment's Pods to roll before it takes effect.

When you're deciding how to change something, ask first: is this a `values.yaml` key under a controller's `extraArgs` (a flag, requires a rollout), or under `config` (a ConfigMap setting, often live)?

## Reference

- `helm show values kyverno/kyverno` — see every `extraArgs` key and its exact nesting for the chart version you have.
- `helm upgrade --reuse-values` — Helm CLI docs for incremental upgrades that keep previously-set values.
- `kubectl get cm -n kyverno -o yaml` — read Kyverno's live ConfigMap to see the current `config.*` settings.
