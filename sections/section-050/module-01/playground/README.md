# Running Kyverno Highly Available - Playground

Status: UNTESTED (written statically, not yet run against a cluster).

- **Slug:** ats-008-playground-050-01
- **Type:** Astrona playground - clean environment, no task, no grading

A single-node kind cluster with the `kyverno` Helm repository added. Kyverno
is not installed: you install it yourself with different replica counts and
watch what each controller does. Nothing is submitted.

## Run it

```sh
astrona run -c .
astrona destroy ats-008-playground-050-01
```

`astrona destroy` takes the environment name, not the path.

## Layout

| Path | Purpose |
| --- | --- |
| `config.yaml` | Environment definition and the bootstrap script |
| `bootstrap/prepare.sh` | Adds and updates the Kyverno Helm repository |
| `docs/overview.md` | What the environment contains and ideas to try |
