# Solution Walkthrough

All three changes belong to the `config` block of the Helm values. You write one values file, apply it with one upgrade and read the ConfigMap back. Run `astrona submit` after the upgrade to see each check.

## Step 1: Write the values file

Save this as `configmap-values.yaml`:

```yaml
config:
  excludeUsernames:
    - system:serviceaccount:mission-ops:flight-bot
  generateSuccessEvents: true
  resourceFiltersIncludeNamespaces:
    - mission-ops
```

`excludeUsernames` skips one sender. `generateSuccessEvents` makes Kyverno write an event for passing rules. `resourceFiltersIncludeNamespaces` adds `[*/*,mission-ops,*]` to the default filters. If you set `config.resourceFilters` instead, you replace the whole default list, and the filter check fails. You did not set `excludeGroups`, so `system:nodes` stays.

Check what Helm would build, without touching the cluster:

```sh
helm template kyverno kyverno/kyverno -n kyverno -s templates/config/configmap.yaml \
  -f configmap-values.yaml | grep -n "excludeUsernames\|generateSuccessEvents\|mission-ops"
```

## Step 2: Apply the upgrade

```sh
helm upgrade --reuse-values -n kyverno kyverno kyverno/kyverno -f configmap-values.yaml
```

Run `astrona submit -c sections/section-030/module-02/labs/lab-01`. All four checks should pass. The ConfigMap changes at once, and the controllers read it live, so there is nothing to wait for.

## Step 3: Verify your configuration

```sh
kubectl get configmap kyverno -n kyverno \
  -o jsonpath='{.data.excludeUsernames}{"\n"}{.data.generateSuccessEvents}{"\n"}{.data.excludeGroups}{"\n"}'
kubectl get configmap kyverno -n kyverno -o jsonpath='{.data.resourceFilters}' | tr ' ' '\n' | grep -n "mission-ops\|Event"
```

The first command prints the user, `true` and `system:nodes`. The second shows the `mission-ops` filter and the default `[Event,*,*]` entry, so the defaults are still there.
