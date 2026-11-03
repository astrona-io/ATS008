# Summary

Well flown, astronaut. You have finished every part of this module. This page recaps what you learned, lists your mission, lets you check yourself and ends with cleaning up your playground.

## What you learned

This module was about the station notice board: the ConfigMap `kyverno` that all four crews read live.

**[Reading the Kyverno ConfigMap](./course-01-reading-the-kyverno-configmap.md):**

- The chart builds the ConfigMap `kyverno` from the `config` block of the values. The controllers find it through `INIT_CONFIG`.
- The keys include `excludeGroups`, `excludeUsernames`, `resourceFilters`, `generateSuccessEvents`, `defaultRegistry`, `webhooks` and `updateRequestThreshold`. A key with no value is left out.
- Read the live board with `kubectl get configmap kyverno -n kyverno`, and the planned board with `helm template ... -s templates/config/configmap.yaml`.
- The crews read the ConfigMap live, so a change needs no restart.

**[Changing the ConfigMap with Helm](./course-02-changing-the-configmap-with-helm.md):**

- The exclude lists skip the sender, and the resource filters skip the target. Both skip the check completely.
- A list you set replaces the old list. Write every entry you want to keep.
- Use the four helper lists (`resourceFiltersIncludeNamespaces`, `resourceFiltersExcludeNamespaces`, `resourceFiltersInclude`, `resourceFiltersExclude`) instead of replacing `resourceFilters`.
- `generateSuccessEvents` is off by default. After an upgrade, the ConfigMap changes and the Pods stay as they are.

## Your missions

You proved this skill in a graded mission:

| Mission | After the part | What you proved |
| --- | --- | --- |
| [The Kyverno ConfigMap Lab](./labs/lab-01/README.md) | Changing the ConfigMap with Helm | change the Kyverno ConfigMap through Helm values without losing the defaults |

If you skipped it, go back to it now.

## Check yourself

Try to answer each question before you open the answer.

<details>
<summary>1. Which object holds the settings that the crews read live?</summary>

The ConfigMap `kyverno` in the `kyverno` namespace. The chart builds it from the `config` values.
</details>

<details>
<summary>2. You run <code>kubectl edit configmap kyverno</code> and add a group. What happens at the next <code>helm upgrade</code>?</summary>

Helm rebuilds the ConfigMap from your values, and your hand edit is lost. Change the Helm values instead.
</details>

<details>
<summary>3. What is the difference between <code>excludeGroups</code> and <code>resourceFilters</code>?</summary>

`excludeGroups` skips requests by who sends them. `resourceFilters` skips requests by what they target: a kind, a namespace or a name.
</details>

<details>
<summary>4. You want Kyverno to ignore the namespace <code>mission-ops</code>. How do you add it without copying the default filters?</summary>

Set `config.resourceFiltersIncludeNamespaces` to a list with `mission-ops`. The chart adds `[*/*,mission-ops,*]` to the default filters.
</details>

<details>
<summary>5. You change <code>config.generateSuccessEvents</code> with <code>helm upgrade</code>. Do the Kyverno Pods restart?</summary>

No. The ConfigMap changes and the crews read it live. Only a flag change replaces Pods.
</details>

## Clean up

The playground and each mission run their own cluster on your machine. When you are done with this module, check that none is still running.

First, see what is still running:

```sh
astrona list
```

If something from this module is still listed, remove it by its **name**, not its folder path:

```sh
astrona destroy ats-008-lab-016
astrona destroy ats-008-playground-030-02
```

Run `astrona list` again to check that everything is gone.

> *The notice board is read live: pin a note through Helm, never by hand, and keep the defaults.*

<!-- astrona:playground:destroy -->
