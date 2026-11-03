# Kyverno's CRD Surface - Playground

Status: UNTESTED (written statically, not yet run against a cluster).

- **Slug:** ats-008-playground-020-01
- **Type:** Astrona playground - clean environment, no task, no grading

A training solar system (a `kind` cluster) with **Kyverno v1.13.2**, installed from the release `install.yaml` file. The namespace `checkout` and the `ClusterPolicy` `require-owner-label` (rule `check-owner-label`, `Enforce`, every Pod needs an `owner` label) are ready. `PolicyException` support is still switched off. Nothing is submitted.

## Run it

```sh
astrona run -c .
astrona destroy ats-008-playground-020-01
```

`astrona destroy` takes the environment name, not the path.

## Layout

| Path | Purpose |
| --- | --- |
| `config.yaml` | Environment definition |
| `bootstrap/prepare.sh` | Installs Kyverno v1.13.2, creates `checkout` and the policy |
| `docs/overview.md` | What is in the box, helpers and practice tasks |
