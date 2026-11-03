# Upgrading a Running Kyverno Installation - Playground

- **Slug:** ats-008-playground-060-01
- **Type:** Astrona playground - clean environment, no task, no grading
- **Status:** UNTESTED (written statically, not yet run against a cluster).

A `kind` cluster with the `kyverno` Helm repository added and Kyverno installed
with Helm at the chart's default values: release `kyverno` in namespace
`kyverno`, revision 1. Nothing is submitted.

## Run it

```sh
astrona run -c .
astrona destroy ats-008-playground-060-01
```

`astrona destroy` takes the environment name (`metadata.name`), not the config
path. `astrona submit` does not apply because there is no grading.

## Layout

| Path | Purpose |
| --- | --- |
| `config.yaml` | Environment definition and the bootstrap script |
| `bootstrap/prepare.sh` | Adds the Helm repository, installs Kyverno and waits for the four controllers |
| `docs/overview.md` | What the environment contains, helper functions and ideas to try |
