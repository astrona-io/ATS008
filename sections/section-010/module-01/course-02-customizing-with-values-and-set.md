# Part 2 — Customizing the Install: values.yaml & --set

> Prerequisite: [Part 1 — Adding the Repo & a Baseline Install](./course-01-adding-the-repo-and-a-baseline-install.md). Next: [Section 020 — Kyverno's CRD Surface](../../section-020/module-01/course.md).

A baseline `helm install` gets you a working Kyverno, but the chart's `values.yaml` is where you actually shape the deployment — how many replicas each controller runs, how much CPU/memory they request, whether Helm manages the CRDs at all, and dozens of other settings. You reach these values two ways: a handful of `--set key=value` flags on the command line, or a `-f values.yaml` file for anything more than a couple of overrides.

## CRD management: `crds.install`

```yaml
crds:
  install: true   # default
```

Kyverno's CRDs are installed as a dedicated chart dependency, gated by this single boolean. Leave it `true` (the default) and Helm installs and — critically, as you'll see in Section 060 — keeps the CRDs up to date on every `helm upgrade`. Set it `false` only if something else in your pipeline manages Kyverno's CRDs independently.

## Sizing the admission controller

Two values.yaml paths matter most day-to-day:

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

Note the nesting: `replicas` sits directly under `admissionController`, but `resources` sits one level deeper, under `admissionController.container`. This inconsistency is not unique to `admissionController` — you'll meet it again, more sharply, when setting controller command-line flags in Section 030.

The other three controllers each have their own `enabled` toggle:

```yaml
backgroundController:
  enabled: true   # default

reportsController:
  enabled: true   # default

cleanupController:
  enabled: true   # default
```

## `-f values.yaml` vs many `--set` flags

For one or two overrides, `--set` is fine:

```sh
helm install kyverno kyverno/kyverno -n kyverno --create-namespace \
  --set admissionController.replicas=2 \
  --set admissionController.container.resources.requests.cpu=100m \
  --set admissionController.container.resources.requests.memory=128Mi
```

For anything larger, a values file is easier to read, review, and version-control:

```yaml
# values.yaml
admissionController:
  replicas: 2
  container:
    resources:
      requests:
        cpu: 100m
        memory: 128Mi
```

```sh
helm install kyverno kyverno/kyverno -n kyverno --create-namespace -f values.yaml
```

## The idempotent pattern: `helm upgrade --install`

Once a release might already exist, prefer `helm upgrade --install` over `helm install` — it installs the release if it's missing and upgrades it in place if it's already there, which makes the exact same command safe to re-run in a CI pipeline:

```sh
helm upgrade --install kyverno kyverno/kyverno -n kyverno --create-namespace -f values.yaml
```

## Auditing what actually landed

Your values file describes *intent*. To see the *effective* configuration Helm actually merged (your overrides layered on top of the chart's defaults), use:

```sh
helm get values kyverno -n kyverno -a
```

The `-a` (`--all`) flag is the important part — without it, `helm get values` only shows the values *you* explicitly set, hiding everything still at its chart default. Before installing at all, `helm show values kyverno/kyverno` prints the chart's full default `values.yaml` so you know what you're overriding.

> [!TIP]
> **Try it — see your override next to every default**
>
> ```sh
> helm get values kyverno -n kyverno -a | grep -A3 admissionController
> ```
>
> Expect to see your `replicas: 2` sitting right next to every other `admissionController.*` default the chart ships with — this is the fastest way to confirm a `--set` flag actually took effect versus silently being ignored due to a typo in the key path.

> [!WARNING]
> **Common pitfall — Helm replaces lists, it does not merge them**
>
> Kyverno's default `config.excludeGroups` is `["system:serviceaccounts:kube-system", "system:nodes"]`. If you override it like this:
>
> ```sh
> --set config.excludeGroups[0]="system:serviceaccounts:ci"
> ```
>
> you have not *added* a third excluded group — you have **replaced the entire list** with a single entry, silently dropping the two built-in defaults. Kyverno's own components and system Pods could now become subject to policies they were previously exempt from. Any time you override a list-valued setting, re-list every entry you want to keep, not just the new one:
>
> ```yaml
> config:
>   excludeGroups:
>     - "system:serviceaccounts:kube-system"
>     - "system:nodes"
>     - "system:serviceaccounts:ci"
> ```

## Reference

- `helm show values kyverno/kyverno` — the chart's complete default `values.yaml`, useful to read before writing your own overrides.
- Kyverno's Helm chart `values.yaml` on GitHub — the authoritative source for every configurable key and its default.
