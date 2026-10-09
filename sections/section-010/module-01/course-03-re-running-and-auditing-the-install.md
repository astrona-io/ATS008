# Re-running and Auditing the Install

Astronaut, a station is never assembled only once. You will change its order form again and again, often from a script or a pipeline. This part shows the one command that is safe to run every time, how to read back the configuration Helm really used, and the one trap that silently throws settings away.

## The safe-to-repeat command: `helm upgrade --install`

`helm install` fails if the release already exists. Once a release might be there, use `helm upgrade --install` instead. It installs the release if it is missing and upgrades it in place if it is already there:

```sh
helm upgrade --install kyverno kyverno/kyverno -n kyverno --create-namespace -f values.yaml
```

Because the same command works the first time and every time after, you can run it again and again in a pipeline without breaking anything. Each run adds a new revision to the release's flight record.

## Reading back what really landed

Your values file describes what you *meant*. Helm merges it on top of the chart's own defaults, and the result is what really runs. To see that merged result, read back the complete order form, defaults included:

```sh
helm get values kyverno -n kyverno -a
```

The `-a` flag (long form `--all`) is the important part. Without it, `helm get values` shows only the values *you* set and hides everything still at its chart default.

There is a matching command for before you install anything: `helm show values kyverno/kyverno` prints the chart's default `values.yaml`, so you know what you are about to change.

### Try it on your cluster

On a cluster where you installed Kyverno with `admissionController.replicas=2`, filter the full values for the admission controller:

```sh
helm get values kyverno -n kyverno -a | grep -A3 admissionController
```

Look for your `replicas: 2` next to the admission controller's other default settings. This is the fastest way to prove that a `--set` flag took effect, and was not quietly ignored because of a typo in the key path.

## Lists are replaced, not merged

Some values are lists, and Helm treats them differently from single values. A new list does not add to the old one. It replaces it completely.

Here is a real example. `config.excludeGroups` is the list of groups the inspectors wave through without checking. In older chart versions it held two groups by default, `system:serviceaccounts:kube-system` and `system:nodes`. The current chart (version 3.9.1 when this page was written) holds only `system:nodes`. Check yours with `helm show values kyverno/kyverno`.

Now suppose you want to add a group for your continuous integration (CI) jobs, and you write this:

```sh
--set config.excludeGroups[0]="system:serviceaccounts:ci"
```

You have not *added* a group. You have **replaced the whole list** with one entry, and the default groups are gone. Kyverno's own components and system pods may now be checked by policies they used to skip.

The fix is to list every entry you want to keep, plus the new one. Put this under `config:` in your values file:

```yaml
config:
  excludeGroups:
    - "system:serviceaccounts:kube-system"
    - "system:nodes"
    - "system:serviceaccounts:ci"
```

Then apply the file with `helm upgrade --install` as above, and read the result back from Kyverno's ConfigMap:

```sh
kubectl get cm -n kyverno -o yaml | grep -E "system:serviceaccounts:ci|system:serviceaccounts:kube-system|system:nodes"
```

All three group names should appear.

> [!TIP]
> Before you override any list value, run `helm show values kyverno/kyverno` and copy the current entries into your values file first. Then add the new one.

## Common pitfalls

> [!WARNING]
> - **Using `helm install` in a script that runs more than once.** The second run fails because the release exists. Use `helm upgrade --install`.
> - **Forgetting `-a` on `helm get values`.** Without it, you only see your own overrides and miss every default.
> - **Overriding a list with only the new entry.** Helm replaces lists; it does not merge them. Re-list every entry you want to keep.
