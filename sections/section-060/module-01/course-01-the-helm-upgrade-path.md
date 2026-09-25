# Part 1 — The Helm Upgrade Path

> Prerequisite: [Landing page](./course.md). Next: [Part 2 — Manifest Upgrades & Post-Upgrade Validation](./course-02-manifest-upgrades-and-post-upgrade-validation.md).

## The upgrade command

Helm upgrades an existing release in place with the same command shape you'd expect from any other chart:

```sh
helm upgrade kyverno kyverno/kyverno -n kyverno -f values.yaml
```

or, for a smaller targeted change, `--set` flags instead of a full values file:

```sh
helm upgrade kyverno kyverno/kyverno -n kyverno --reuse-values --set admissionController.replicas=3
```

`--reuse-values` (or `--reuse-values` combined with a new values file) matters here the same way it did back in Section 030: without it, Helm computes the new release from the chart's *defaults* plus whatever you pass on this specific command line — any customization from a previous install or upgrade that you don't explicitly re-specify gets silently dropped. `--reuse-values` merges your new flags on top of the release's last known values instead of starting from scratch.

Both commands reuse the same release name (`kyverno`) and namespace (`kyverno`) as the original install — Helm recognizes this as an upgrade of an existing release, not a new install, and records it as a new **revision** of that release.

## Read the release notes — all of them you're skipping

Before running any upgrade, read Kyverno's release notes for the version you're upgrading *to*. If you're skipping more than one minor version — say, going straight from an older release to a much newer one — read the release notes for **every minor version in between**, not just the destination. Kyverno's own documentation calls out a concrete example of why this matters: "Kyverno 1.10 brought breaking changes making upgrades to it or versions after 1.10 limited in nature." A user who jumped straight past 1.10 without reading its notes could hit a breaking change they had no warning about, even though the target version's own notes looked harmless in isolation.

> [!TIP]
> **Try it — see what chart versions are available before you upgrade**
>
> ```sh
> helm repo update
> helm search repo kyverno/kyverno --versions
> helm show chart kyverno/kyverno
> ```
>
> `helm search repo ... --versions` lists every chart version Helm knows about from the repo you added in Section 010 — useful for confirming exactly what version you're about to move to (and everything in between) before you read release notes for it.

## The CRD-upgrade trap Kyverno avoids

This is the single most counter-intuitive fact in this module, and it runs backwards from what most Helm users have learned to expect.

Many Helm charts place their CRDs in a special `crds/` directory inside the chart. Helm installs those CRDs the first time you run `helm install`, but **`helm upgrade` never touches that directory again** — it's a deliberate Helm design decision to avoid ever deleting a CRD (and the custom resources built on it) as a side effect of an upgrade or rollback. The practical consequence for those charts: if a new chart version ships an updated CRD schema, you must apply the new CRD YAML yourself, manually, before or alongside the `helm upgrade`.

> [!WARNING]
> **The opposite of what most Helm users expect**
>
> Kyverno's chart does **not** use that special `crds/` directory. Its CRDs are shipped as ordinary templated resources inside a dedicated CRD chart dependency (controlled by the `crds.install` value from Section 010), not the crds-folder mechanism. That means a normal `helm upgrade kyverno kyverno/kyverno` **does** pick up CRD schema changes automatically, with no manual `kubectl apply` step required. If you walk into a Kyverno upgrade assuming you need to hand-apply new CRDs first — because that's the rule for most other charts — you'll waste time on a step Kyverno already handles for you. Conversely, don't assume every chart behaves this way; Kyverno is the exception, not the rule.

## Reference

- `helm upgrade --help` — full flag reference, including `--reuse-values`, `--install` (upgrade-or-install), and `--version` (pin a specific chart version).
- Kyverno's release notes / GitHub Releases page — read before every upgrade, including every intermediate minor version you're skipping.
