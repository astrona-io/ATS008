# Part 2 — Manifest Upgrades & Post-Upgrade Validation

> Prerequisite: [Part 1 — The Helm Upgrade Path](./course-01-the-helm-upgrade-path.md). This is the last reading in Section 060 — take the [Section 060 Knowledge Check Quiz](../quiz.md) next, then the [final domain quiz](../final-domain-quiz.md) once you've completed every section.

## Manifest installs have no in-place upgrade

If you installed Kyverno the way ATS007's labs bootstrap it — `kubectl create -f https://github.com/kyverno/kyverno/releases/download/vX.Y.Z/install.yaml` — you did not create a Helm release. There is no `helm upgrade` available to you, because there is no release for Helm to track. The documented procedure for moving a manifest-based install to a new version is:

```sh
# 1. Uninstall using the exact manifest URL you originally installed with
kubectl delete -f https://github.com/kyverno/kyverno/releases/download/vOLD/install.yaml

# 2. Install the new version's manifest fresh
kubectl create -f https://github.com/kyverno/kyverno/releases/download/vNEW/install.yaml
```

This is a real uninstall-then-reinstall, not an in-place edit — Kyverno's controllers are unavailable for the gap between the two commands. It is one of the concrete, practical reasons Helm is the recommended install method from Section 010 onward: a Helm release gets a genuine rolling upgrade, a manifest install does not.

> [!WARNING]
> **Common pitfall**
>
> Deleting the *new* version's manifest by mistake, or deleting with a manifest that doesn't exactly match what was originally installed, can leave orphaned resources behind (or fail to remove some). Always uninstall with the same manifest URL you used to install — don't assume `kubectl delete -f <whatever the new install.yaml is>` will cleanly reverse an old install.

## Post-upgrade schema migration: `kyverno migrate`

When a new Kyverno version changes the stored schema of a CRD your cluster already has resources for, the Kyverno CLI ships a migration helper to bring existing objects up to date:

```sh
kyverno migrate --resource policyexceptions.kyverno.io
```

Check the release notes for the version you're upgrading to for whether a migration step like this is required — not every upgrade needs one, but skipping a required migration can leave older stored objects unreadable by the new controller version.

## The backup-and-verify checklist

Before you touch anything, back up the policies already running on the cluster:

```sh
kubectl get clusterpolicy,policy -A -o yaml > policy-backup.yaml
```

This is cheap insurance: if an upgrade goes sideways, you have the exact policy state to reapply or diff against, without having to reconstruct it from memory or from a separate Git repo that might be out of date.

After the upgrade — Helm or manifest — confirm health before calling it done:

```sh
# Helm-based: confirm the release actually moved to a new revision
helm status kyverno -n kyverno
helm history kyverno -n kyverno

# Either method: confirm every controller rolled out cleanly
kubectl rollout status deployment/kyverno-admission-controller -n kyverno
kubectl rollout status deployment/kyverno-background-controller -n kyverno
kubectl rollout status deployment/kyverno-reports-controller -n kyverno
kubectl rollout status deployment/kyverno-cleanup-controller -n kyverno

# Confirm the cluster is actually healthy, not just "the command exited 0"
kubectl get pods -n kyverno
```

> [!TIP]
> **Try it — confirm a policy survived the upgrade untouched**
>
> ```sh
> kubectl get clusterpolicy <name> -o yaml
> ```
>
> Diff this against your `policy-backup.yaml` (or just eyeball the `spec`) to confirm the upgrade didn't silently alter a policy you didn't touch. A policy's `spec` should be completely unaffected by a Kyverno version upgrade — only the controllers evaluating it changed.

## Reference

- `kyverno migrate --help` — the Kyverno CLI's migration subcommand.
- `helm history <release> -n <namespace>` — full revision history for a release, useful for confirming an upgrade happened and for identifying a revision to `helm rollback` to if needed.
- `kubectl rollout status deployment/<name> -n <namespace>` — blocks until a Deployment's rollout finishes, the standard way to confirm a controller actually came back up after an upgrade.
