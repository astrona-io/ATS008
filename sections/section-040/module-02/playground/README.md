# Permissions for the Cleanup, Reports and Admission Controllers - Playground

- **ID:** PLAYGROUND
- **Slug:** ats-008-playground-040-02
- **Author:** Paris Nakita Kejser
- **Type:** Astrona playground - clean environment, no task, no grading
- **Status:** UNTESTED (written statically, not yet run against a cluster).

A single-node kind cluster with the latest `kyverno/kyverno` Helm chart at
default values (release `kyverno`, namespace `kyverno`). The namespace
`debris` holds the ConfigMaps `old-log-1` and `old-log-2` (label
`stale=true`) and `keep-log` (label `stale=false`). The custom resource
kind `Beacon` (`beacons.fleet.example.com`) has one object, `beacon-1` in
namespace `harbor`, with no `owner` label, and the ClusterPolicy
`beacons-need-owner` checks it in `Audit` mode. No extra permissions are
granted. Nothing is submitted.

## Run it

```sh
astrona run -c .
astrona destroy ats-008-playground-040-02
```

## Layout

| Path | Purpose |
| --- | --- |
| `config.yaml` | Environment definition and the bootstrap script |
| `bootstrap/prepare.sh` | Installs Kyverno and creates the namespaces, ConfigMaps, CRD, Beacon and policy |
| `docs/overview.md` | What the environment contains and practice tasks |
