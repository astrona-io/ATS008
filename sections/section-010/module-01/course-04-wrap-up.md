# Wrap-Up: Mission Debrief

Well flown, astronaut. You have finished every part of this module. Before you move on, look back at what you learned, check yourself, and make sure no mission cluster is still running.

## What you learned

This module was about building the inspection authority itself: installing Kyverno with Helm and shaping it with values.

**From [Adding the Repo & a Baseline Install](./course-01-adding-the-repo-and-a-baseline-install.md):**

- `helm repo add kyverno https://kyverno.github.io/kyverno/` and `helm repo update` make the chart available as `kyverno/kyverno`.
- Kyverno must live alone in a dedicated namespace, by convention `kyverno`.
- `helm install kyverno kyverno/kyverno -n kyverno --create-namespace` is the baseline install. The first `kyverno` is the release name.
- Check three layers after an install: the pods, the custom resource definitions (`kubectl get crd | grep kyverno.io`) and the release (`helm list`, `helm status`).

**From [Customizing the Install: values.yaml & --set](./course-02-customizing-with-values-and-set.md):**

- `crds.install` (default `true`) decides whether Helm installs and updates Kyverno's custom resource definitions.
- `admissionController.replicas` sits directly under the controller; `resources` sits under `admissionController.container`.
- Each of the other three controllers has an `enabled` switch.
- Use `--set` for one or two changes, and a values file with `-f` for more.

**From [Re-running and Auditing the Install](./course-03-re-running-and-auditing-the-install.md):**

- `helm upgrade --install` is safe to run again and again.
- `helm get values -a` shows the real, merged configuration; without `-a` you only see your own overrides.
- Helm replaces list values such as `config.excludeGroups`. Re-list every entry you want to keep.

## Your missions

You proved these skills in graded missions:

| Mission | After the part | What you proved |
| --- | --- | --- |
| [Helm Install with Custom Values](./labs/lab-01/README.md) | Customizing the Install: values.yaml & --set | install Kyverno into its own namespace and size the admission controller |
| [Helm-based Installation and Configuration Capstone](../capstone/labs/lab-01/README.md) | End of the section | install from a values file, switch off a controller and extend a list safely |

If you skipped one, go back to it now.

## Check yourself

Try to answer each question before you open the answer.

<details>
<summary>1. What does <code>helm repo add</code> download?</summary>

Nothing yet. It only saves the repository address under a local name. `helm repo update` fetches the list of chart versions.
</details>

<details>
<summary>2. In <code>helm install kyverno kyverno/kyverno -n kyverno</code>, which word is the release name?</summary>

The first `kyverno`, right after `install`. `kyverno/kyverno` is the repository name and the chart name, and `-n kyverno` is the namespace.
</details>

<details>
<summary>3. Why must Kyverno have its own namespace?</summary>

Kyverno's webhook sees writes across the whole cluster. Keeping its controllers, service accounts and permissions alone in one namespace makes them easier to see and to lock down.
</details>

<details>
<summary>4. You set <code>admissionController.resources.requests.cpu=100m</code>. The Deployment still shows the old request. Why?</summary>

The key path is wrong. Resources sit under `admissionController.container.resources`. Helm ignores a key the chart never reads, so there is no error.
</details>

<details>
<summary>5. What does the <code>-a</code> flag add to <code>helm get values</code>?</summary>

Every value still at its chart default. Without it, you only see the values you set yourself.
</details>

<details>
<summary>6. You add a group with <code>--set config.excludeGroups[0]=...</code>. What happened to the existing groups?</summary>

They are gone. Helm replaced the whole list with your one entry. List every group you want to keep, plus the new one.
</details>

## Clean up

Each mission runs its own cluster on your machine. When you are done with this module, check that none is still running.

First, see what is still running:

```sh
astrona list
```

If a mission from this module is still listed, remove it by its **name**, not its folder path:

```sh
astrona destroy ats-008-lab-001
astrona destroy ats-008-lab-002
```

Run `astrona list` again to check that everything is gone.

> *Add the depot, install on Kyverno's own planet, and always read back what really landed.*
