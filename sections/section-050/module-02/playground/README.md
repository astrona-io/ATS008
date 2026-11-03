# Sizing, Disruption Budgets and Spreading Replicas - Playground

Status: UNTESTED (written statically, not yet run against a cluster).

- **Slug:** ats-008-playground-050-02
- **Type:** Astrona playground - clean environment, no task, no grading

A single-node kind cluster with Kyverno installed with Helm at default values:
release `kyverno` in namespace `kyverno`, one replica per controller. You
resize it with `helm upgrade`. Nothing is submitted.

## Run it

```sh
astrona run -c .
astrona destroy ats-008-playground-050-02
```

`astrona destroy` takes the environment name, not the path.

## Layout

| Path | Purpose |
| --- | --- |
| `config.yaml` | Environment definition and the bootstrap script |
| `bootstrap/prepare.sh` | Adds the Helm repository and installs Kyverno at default values |
| `docs/overview.md` | What the environment contains and ideas to try |
