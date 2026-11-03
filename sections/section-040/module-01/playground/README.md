# Kyverno's RBAC Model - Playground

- **ID:** PLAYGROUND
- **Slug:** ats-008-playground-040-01
- **Author:** Paris Nakita Kejser
- **Type:** Astrona playground - clean environment, no task, no grading
- **Status:** UNTESTED (written statically, not yet run against a cluster).

A single-node kind cluster with the latest `kyverno/kyverno` Helm chart
installed as release `kyverno` in namespace `kyverno`. The ClusterPolicy
`generate-default-quota` creates a ResourceQuota named `default-quota` in
every new namespace. The background controller has no permission to create
ResourceQuotas (the chart's default grant was removed on purpose), so a new
namespace gets no quota until you add an aggregated ClusterRole. Nothing is
submitted.

## Run it

```sh
astrona run -c .
astrona destroy ats-008-playground-040-01
```

`astrona destroy` takes the environment name (`metadata.name`), not the
config path.

## Layout

| Path | Purpose |
| --- | --- |
| `config.yaml` | Environment definition and the bootstrap script |
| `bootstrap/prepare.sh` | Installs Kyverno, applies the policy, removes the chart's default extra permissions |
| `docs/overview.md` | What the environment contains and practice tasks |
