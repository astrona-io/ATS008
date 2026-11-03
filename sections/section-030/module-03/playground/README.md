# Webhooks, Failure Policy and Certificates - Playground

- **ID:** PLAYGROUND
- **Slug:** ats-008-playground-030-03
- **Author:** Paris Nakita Kejser
- **Type:** Astrona playground - clean environment, no task, no grading
- **Status:** UNTESTED (written statically, not yet run against a cluster).

A single-node kind cluster (Kubernetes 1.35, `kindest/node:v1.35.8`) with Kyverno installed with Helm at default values (release `kyverno`, namespace `kyverno`), an empty namespace named `mission-ops` and the ClusterPolicy `audit-owner-label` in Audit mode. Nothing is submitted.

## Run it

```sh
astrona run -c .
astrona destroy ats-008-playground-030-03
```

`astrona destroy` takes the environment name (`metadata.name`), not the config path. `astrona submit` and `astrona test` do not apply because there is no grading.

## Layout

| Path | Purpose |
| --- | --- |
| `config.yaml` | Environment definition and the bootstrap script |
| `bootstrap/prepare.sh` | Adds the Helm repository, installs Kyverno, waits for the four Deployments, creates `mission-ops` and applies the policy |
| `manifests/mission-ops.yaml` | The `mission-ops` namespace |
| `manifests/audit-owner-label.yaml` | A ClusterPolicy that audits Pods without an `owner` label, so that Kyverno has a rule to register in its webhooks |
| `docs/overview.md` | What the environment contains, helper functions and ideas to try |
