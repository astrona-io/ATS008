# Reading Policy Reports and Intermediate Reports - Playground

Status: UNTESTED (written statically, not yet run against a cluster).

- **Slug:** ats-008-playground-020-03
- **Type:** Astrona playground - clean environment, no task, no grading

A training solar system (a `kind` cluster) with the **current `kyverno/kyverno` Helm chart** (chart 3.9.x, Kyverno v1.19.x) as release `kyverno` in the namespace `kyverno`. The namespace `hangar` (label `env: prod`) holds the Deployments `falcon` (labels `owner` and `team`), `comet` (only `team`), `nova` (no labels) and `pulsar` (only `owner`). The namespace `depot` has no labels. The `ClusterPolicy` `require-crew-labels` and `require-planet-env` run in `Audit` mode. Nothing is submitted.

## Run it

```sh
astrona run -c .
astrona destroy ats-008-playground-020-03
```

## Layout

| Path | Purpose |
| --- | --- |
| `config.yaml` | Environment definition |
| `bootstrap/prepare.sh` | Helm install, policies and Deployments |
| `docs/overview.md` | What is in the box, helpers and practice tasks |
