# Rolling Back and Recovering from a Bad Upgrade - Playground

- **Slug:** ats-008-playground-060-02
- **Type:** Astrona playground - clean environment, no task, no grading
- **Status:** UNTESTED (written statically, not yet run against a cluster).

A `kind` cluster with Kyverno installed with Helm (release `kyverno`, namespace
`kyverno`). Revision 1 is the clean install. Revision 2 is a broken upgrade: the
admission controller image tag does not exist, and the upgrade did not use
`--wait`, so Helm shows revision 2 as deployed. The namespace `finance` and the
ClusterPolicy `require-cost-center-label` already exist. Nothing is submitted.

## Run it

```sh
astrona run -c .
astrona destroy ats-008-playground-060-02
```

`astrona destroy` takes the environment name (`metadata.name`), not the config
path. `astrona submit` does not apply because there is no grading.

## Layout

| Path | Purpose |
| --- | --- |
| `config.yaml` | Environment definition and the bootstrap script |
| `bootstrap/prepare.sh` | Installs revision 1, seeds the policy, applies the broken revision 2 |
| `docs/overview.md` | What the environment contains, helper functions and ideas to try |
