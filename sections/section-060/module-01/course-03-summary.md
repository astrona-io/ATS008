# Summary

An upgrade is a refit of a station in orbit. Helm writes the new entry in the flight record, and Kubernetes swaps the ships one by one. You read the flight record before and after, and you check the ships yourself.

## What you learned

[The Helm Upgrade Path](./course-01-the-helm-upgrade-path.md) showed the command `helm upgrade kyverno kyverno/kyverno -n kyverno`. Without `--reuse-values`, every value you did not repeat goes back to the chart default. `--version` picks the chart version, and you read the release notes for every minor version you skip. Kyverno's CRDs are ordinary chart templates (the value `crds.install`), so a normal upgrade updates them, and a post-upgrade hook Job runs `kyverno migrate` for you.

[Manifest Upgrades and Post-Upgrade Validation](./course-02-manifest-upgrades-and-post-upgrade-validation.md) showed that an install made with `install.yaml` has no flight record. You remove it with the old manifest and install the new one, with an outage in between. Around any upgrade you back up policies with `kubectl get clusterpolicies.kyverno.io,policies.kyverno.io -A -o yaml`, then check `helm status`, `helm history`, the four rollouts and the pods.

## Missions

| Mission | What it proves |
| --- | --- |
| Upgrading a Live Kyverno Release Lab (`ats-008-lab-011`) | You upgrade with `--reuse-values`, see revision 2 in the history and keep every pod healthy |

## Check yourself

- Why does a manifest install have no `helm upgrade`?
- Which flag keeps your earlier values on an upgrade?
- Which command shows one row per revision?
- Why do you not apply CRD files by hand before a Kyverno upgrade?

Clean up the playground when you are done:

```sh
astrona list
astrona destroy ats-008-playground-060-01
```

<!-- astrona:playground:destroy -->
