# Tuning Kyverno's Controllers with Flags - Playground

- **ID:** PLAYGROUND
- **Slug:** ats-008-playground-030-01
- **Author:** Paris Nakita Kejser
- **Type:** Astrona playground - clean environment, no task, no grading
- **Status:** UNTESTED (written statically, not yet run against a cluster).

A single-node kind cluster (Kubernetes 1.35, `kindest/node:v1.35.8`) with the `kyverno` Helm repository added and Kyverno installed at the chart's default values: release `kyverno` in namespace `kyverno`, with the admission, background, reports and cleanup controllers running. Nothing is submitted.

## Run it

```sh
astrona run -c .
astrona destroy ats-008-playground-030-01
```

`astrona destroy` takes the environment name (`metadata.name`), not the config path. `astrona submit` and `astrona test` do not apply because there is no grading.

## Layout

| Path | Purpose |
| --- | --- |
| `config.yaml` | Environment definition and the bootstrap script |
| `bootstrap/prepare.sh` | Adds the Helm repository, installs Kyverno and waits for the four Deployments |
| `docs/overview.md` | What the environment contains, helper functions and ideas to try |
