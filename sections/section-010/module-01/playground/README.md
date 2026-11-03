# Helm Install and Configuration - Playground

- **Slug:** ats-008-playground-010-01
- **Type:** Astrona playground - clean environment, no task, no grading
- **Status:** UNTESTED (written statically, not yet run against a cluster).

A single-node `kind` cluster (a training solar system) with `kubectl` and `helm`
ready. The `kyverno` Helm repository is already added. Kyverno is **not**
installed: installing it is part of the practice.

## Run it

```sh
astrona run -c .
astrona destroy ats-008-playground-010-01
```

`astrona destroy` takes the environment name (`metadata.name`), not the path.
`astrona submit` does not apply because there is no grading.

## Layout

| Path | Purpose |
| --- | --- |
| `config.yaml` | Environment definition and the bootstrap script |
| `bootstrap/prepare.sh` | Adds and updates the `kyverno` Helm repository |
| `docs/overview.md` | What the environment contains, helpers and practice tasks |
