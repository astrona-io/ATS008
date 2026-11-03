# Reading the Kyverno ConfigMap

The Kyverno ConfigMap is the station notice board. Helm builds it from the `config` block of the chart values, and the four controllers watch it. This part shows what is on the board by default, what each key means, and how to read it in two ways: from the cluster and from `helm template`.

## Where the board comes from

When you install the chart, it creates a ConfigMap named `kyverno` in the release namespace. Each controller finds it through the environment variable `INIT_CONFIG`, which the chart sets to the ConfigMap's name. A few `config` values describe the ConfigMap itself:

| Value | Default | What it does |
| --- | --- | --- |
| `config.create` | `true` | Whether the chart creates the ConfigMap at all |
| `config.name` | not set | The ConfigMap's name, needed when `create` is `false` |
| `config.preserve` | `true` | Keeps the ConfigMap when the release is removed |

Helm marks the ConfigMap with the annotation `helm.sh/resource-policy: "keep"`. That is why it can stay behind after an uninstall.

### The keys on the board

Each other `config` value becomes a key in the ConfigMap's `data`. These are the ones to know:

| Chart value | What the crews do with it |
| --- | --- |
| `config.excludeGroups` | Requests from these groups are waved through without checking (default: `system:nodes`) |
| `config.excludeUsernames` | The same, for single user names |
| `config.excludeRoles`, `config.excludeClusterRoles` | The same, for people who hold these roles |
| `config.resourceFilters` | Kinds, namespaces and names that Kyverno skips completely |
| `config.generateSuccessEvents` | Whether Kyverno also writes an event when a rule passes (default: `false`) |
| `config.defaultRegistry` and `config.enableDefaultRegistryMutation` | The registry host that Kyverno adds to image names that have none (default: `docker.io`, switched on) |
| `config.webhooks` | Which namespaces and objects the webhooks cover |
| `config.updateRequestThreshold` | How many waiting work orders Kyverno allows (default: `1000`) |

A key only appears when it has a value. The empty lists (`excludeUsernames: []` and the two role lists) leave no key behind.

The chart also builds a second ConfigMap, `kyverno-metrics`, from the `metricsConfig` block. It holds settings for metrics only, and it is not the board this module is about.

## Read the board

You can read the live ConfigMap, and you can ask Helm what it would build. If the two agree, nobody has changed the board by hand.

<!-- astrona:playground:renew -->

### See it in your playground

List the keys that are on the board right now:

```sh
kubectl get configmap kyverno -n kyverno \
  -o go-template='{{range $key, $value := .data}}{{$key}}{{"\n"}}{{end}}'
```

You should see keys such as `excludeGroups`, `resourceFilters` and `webhooks`. Now read one value:

```sh
kubectl get configmap kyverno -n kyverno -o jsonpath='{.data.excludeGroups}'
```

The default is `system:nodes`. The kubelets, which are the engines on each space dock, are never checked.

Read the filters. They sit in one long value, so the next command puts each entry on its own line:

```sh
kubectl get configmap kyverno -n kyverno -o jsonpath='{.data.resourceFilters}' \
  | tr ' ' '\n' | head -12
```

Each entry has the shape `[Kind,Namespace,Name]`, and `*` means any. An entry such as `[Event,*,*]` says: skip every `Event`, in every namespace, with any name. The list also skips the `kube-system` namespace and Kyverno's own objects.

### Ask Helm what it would build

`helm template` can render a single file of the chart. This one renders the ConfigMap from the chart defaults:

```sh
helm template kyverno kyverno/kyverno -n kyverno -s templates/config/configmap.yaml | head -30
```

The `data` section matches what you read from the cluster. When you plan a change, render first, then apply.

### Find the value in the chart

To see every `config` value, with its default and a short comment, print that part of the chart values:

```sh
helm show values kyverno/kyverno | sed -n '/^config:/,/^metricsConfig:/p' | head -60
```

The comments explain each value. Do not trust a value name you remember from an older chart: the chart you have is the source of truth.

## The board is read live

The crews watch the ConfigMap, so a change is picked up without a restart. A flag, by contrast, needs a new Pod. You can prove this to yourself in the next part, by changing a note and checking that no Pod was replaced.

## Common pitfalls

> [!WARNING]
> - **Editing the ConfigMap by hand.** `kubectl edit configmap kyverno` works for a moment, but the next `helm upgrade` rebuilds the ConfigMap from your values and your edit is gone. Change the Helm values instead.
> - **Expecting an empty list to show up.** A value such as `excludeUsernames: []` leaves no key in the ConfigMap. A missing key means "nothing is excluded".
> - **Reading the metrics ConfigMap by mistake.** The board is `kyverno`, not `kyverno-metrics`.
> - **Confusing the filters with the exclusions.** Resource filters skip kinds, namespaces and names. The exclude lists skip people and groups.
