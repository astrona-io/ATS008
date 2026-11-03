# Changing the ConfigMap with Helm

You now know what is pinned on the notice board. This part shows how to pin a new note the supported way: through the `config` block of your Helm values. You will exclude a user, add a namespace to the resource filters without losing the defaults, and turn on success events. Then you will prove that no crew restarted.

## Which requests Kyverno looks at

Every launch request goes through the registry desk, and the desk calls the inspectors. Two settings decide which requests the inspectors look at. The exclude lists skip the sender: a group, a user name or a role. The resource filters skip the target: a kind, a namespace or a name.

Both are powerful, because a request that is skipped is never checked against any rule book. Use them with care, and keep the lists short.

### Exclude a user

To skip one user, set `config.excludeUsernames`. A service account's user name has the form `system:serviceaccount:<namespace>:<name>`. You will exclude the service account `flight-bot` from the `mission-ops` namespace.

Because the list is a Helm value, setting it again replaces the whole list. For `excludeGroups` this means the default `system:nodes` is gone as soon as you set a list without it. Always write down every entry you want to keep.

### Add to the resource filters without losing the defaults

The default `resourceFilters` list has more than a hundred entries. If you set `config.resourceFilters` yourself, you replace all of them, and Kyverno would start checking its own objects and the cluster's core objects. The chart offers four helper lists that add to or remove from the defaults, so you never have to copy the whole list:

| Helper value | What it does |
| --- | --- |
| `config.resourceFiltersIncludeNamespaces` | Adds `[*/*,<namespace>,*]` to the filters, so the namespace is skipped |
| `config.resourceFiltersExcludeNamespaces` | Removes the filter line for that namespace, so Kyverno checks it again |
| `config.resourceFiltersInclude` | Adds your own `[Kind,Namespace,Name]` entries |
| `config.resourceFiltersExclude` | Removes the exact entries you list from the defaults |

The word "include" here means "include in the skip list". It does not mean "include in the checking".

## Do it in your playground

<!-- astrona:playground:renew -->

### See it in your playground

Save this as `configmap-values.yaml`:

```yaml
config:
  excludeUsernames:
    - system:serviceaccount:mission-ops:flight-bot
  generateSuccessEvents: true
  resourceFiltersIncludeNamespaces:
    - mission-ops
```

Look first at what Helm would build, without touching the cluster:

```sh
helm template kyverno kyverno/kyverno -n kyverno -s templates/config/configmap.yaml \
  -f configmap-values.yaml | grep -n "excludeUsernames\|generateSuccessEvents\|mission-ops"
```

You should see the user name, the value `"true"` and the line `[*/*,mission-ops,*]` at the end of the filters. Note the time, then write down the names of the Kyverno Pods:

```sh
kubectl get pods -n kyverno
```

Apply the file:

```sh
helm upgrade --reuse-values -n kyverno kyverno kyverno/kyverno -f configmap-values.yaml
```

Read the board again:

```sh
kubectl get configmap kyverno -n kyverno \
  -o jsonpath='{.data.excludeUsernames}{"\n"}{.data.generateSuccessEvents}{"\n"}{.data.excludeGroups}{"\n"}'
```

Your user, `true` and `system:nodes` should all be there. The default group stayed, because you did not touch `excludeGroups`.

Finally, list the Pods again:

```sh
kubectl get pods -n kyverno
```

The Pod names and their ages did not change. The ConfigMap changed, the crews read it live, and nothing was restarted. A flag change would have replaced the Pods of one crew.

## Success events and the default registry

Two more notes on the board are worth knowing. `config.generateSuccessEvents` makes Kyverno write an event for each rule that passes, not only for the ones that fail. It is off by default, because a busy cluster would fill with events. The chart also has `config.successEventActions` to narrow this to some actions.

`config.defaultRegistry` and `config.enableDefaultRegistryMutation` control image names. When a policy mutates a Pod, Kyverno adds the registry host to an image that has none, using `docker.io` by default. Set `enableDefaultRegistryMutation` to `false` to stop that.

## Common pitfalls

> [!WARNING]
> - **Setting `config.resourceFilters` yourself.** It replaces the whole default list. Use the four helper lists to add or remove single entries.
> - **Reading "include" as "check".** `resourceFiltersIncludeNamespaces` adds a namespace to the skip list. Kyverno stops looking at that namespace.
> - **Replacing `excludeGroups` and losing `system:nodes`.** A list you set replaces the old one. Write every group you want to keep.
> - **Forgetting `--reuse-values`.** Without it, an upgrade drops the values you set before.
> - **Excluding too much.** A skipped user or namespace is never checked, so a rule book cannot protect it.

## Your mission: The Kyverno ConfigMap Lab

You can now change the Kyverno ConfigMap through Helm and check the board afterwards. The mission starts a fresh cluster with Kyverno at default values and a namespace named `mission-ops`. It asks you to exclude one service account, turn on success events, and add `mission-ops` to the resource filters while keeping every default entry.

Pause the playground first, so the lab has the memory it needs:

```sh
astrona stop ats-008-playground-030-02
```

Start the lab, then grade it when you are done:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS008.git -c sections/section-030/module-02/labs/lab-01
astrona submit -c sections/section-030/module-02/labs/lab-01
```

When you are done, remove the lab and start the playground again:

```sh
astrona destroy ats-008-lab-016
astrona start ats-008-playground-030-02
```
