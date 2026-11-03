# Cleaning Up Resources with CleanupPolicy and ClusterCleanupPolicy - Playground

Status: UNTESTED (written statically, not yet run against a cluster).

- **Slug:** ats-008-playground-020-02
- **Type:** Astrona playground - clean environment, no task, no grading

A training solar system (a `kind` cluster) with the **current `kyverno/kyverno` Helm chart** (chart 3.9.x, Kyverno v1.19.x) as release `kyverno` in the namespace `kyverno`. The namespace `docking-bay` holds the ConfigMaps `old-scrap` (label `scrap: "true"`) and `keep-me` (no label). No cleanup policy exists. The cleanup controller cannot delete ConfigMaps yet. Nothing is submitted.

## Run it

```sh
astrona run -c .
astrona destroy ats-008-playground-020-02
```

## Layout

| Path | Purpose |
| --- | --- |
| `config.yaml` | Environment definition |
| `bootstrap/prepare.sh` | Helm install and the `docking-bay` objects |
| `docs/overview.md` | What is in the box, helpers and practice tasks |
