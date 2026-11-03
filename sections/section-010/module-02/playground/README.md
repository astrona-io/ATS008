# Installing from Manifests and Removing Kyverno Cleanly - Playground

- **Slug:** ats-008-playground-010-02
- **Type:** Astrona playground - clean environment, no task, no grading
- **Status:** UNTESTED (written statically, not yet run against a cluster).

A single-node `kind` cluster (a training solar system) with `kubectl` and
`helm` ready. Kyverno is installed with Helm as release `kyverno` in the
namespace `kyverno`, at default values. One `ClusterPolicy`,
`require-owner-label`, is applied, so you can see what removal does to it.

## Run it

```sh
astrona run -c .
astrona destroy ats-008-playground-010-02
```

`astrona destroy` takes the environment name (`metadata.name`), not the path.
`astrona submit` does not apply because there is no grading.

## Layout

| Path | Purpose |
| --- | --- |
| `config.yaml` | Environment definition and the bootstrap script |
| `bootstrap/prepare.sh` | Installs Kyverno with Helm, then applies the policy |
| `manifests/require-owner-label.yaml` | The `ClusterPolicy` (Enforce, Pods need an `owner` label) |
| `docs/overview.md` | What the environment contains, helpers and practice tasks |
