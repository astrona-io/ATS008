# The Kyverno ConfigMap - Playground

- **ID:** PLAYGROUND
- **Slug:** ats-008-playground-030-02
- **Author:** Paris Nakita Kejser
- **Type:** Astrona playground - clean environment, no task, no grading
- **Status:** UNTESTED (written statically, not yet run against a cluster).

A single-node kind cluster (Kubernetes 1.35, `kindest/node:v1.35.8`) with Kyverno installed with Helm at default values (release `kyverno`, namespace `kyverno`) and an empty namespace named `mission-ops`. Nothing is submitted.

## Run it

```sh
astrona run -c .
astrona destroy ats-008-playground-030-02
```

`astrona destroy` takes the environment name (`metadata.name`), not the config path. `astrona submit` and `astrona test` do not apply because there is no grading.

## Layout

| Path | Purpose |
| --- | --- |
| `config.yaml` | Environment definition and the bootstrap script |
| `bootstrap/prepare.sh` | Adds the Helm repository, installs Kyverno, waits for the four Deployments and creates `mission-ops` |
| `manifests/mission-ops.yaml` | The `mission-ops` namespace |
| `docs/overview.md` | What the environment contains, helper functions and ideas to try |
