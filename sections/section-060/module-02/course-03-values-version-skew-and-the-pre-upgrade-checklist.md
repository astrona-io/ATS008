# Values, Version Skew and the Pre-Upgrade Checklist

Many bad upgrades are not broken images. They are an order form that lost its settings, or a Kyverno version that does not fit the solar system around it. This part covers the three value flags, the version limits, and a checklist that turns the module into a routine.

The steps below need a healthy release. If `kubectl get pods -n kyverno` still shows an image pull error, roll back first with `helm rollback kyverno 1 -n kyverno --wait`.

<!-- astrona:playground:renew -->

## Three ways to treat your values

Each `helm upgrade` needs an order form. The three flags below decide where that form comes from. Try them in order and read the result after each one.

First, save your current values and upgrade with `--reuse-values`:

```sh
helm get values kyverno -n kyverno -o yaml > values-before.yaml
helm upgrade kyverno kyverno/kyverno -n kyverno --reuse-values --set admissionController.replicas=2
helm get values kyverno -n kyverno
```

The last command lists `admissionController.replicas` as 2. Helm took the last release's values and merged your new `--set` on top.

Now upgrade with `--reset-values`:

```sh
helm upgrade kyverno kyverno/kyverno -n kyverno --reset-values --set backgroundController.replicas=2
helm get values kyverno -n kyverno
```

Now only the background controller setting is listed. `--reset-values` throws away the last release's values and uses the chart's built-in defaults plus what you type. The admission controller replicas went back to the default. Check it with `kubectl get deploy kyverno-admission-controller -n kyverno`.

### The third flag

`--reset-then-reuse-values` resets to the new chart's defaults first, then applies the last release's values, then your overrides. Use it when you move to a new chart version. The reason is that `--reuse-values` can carry the old chart's defaults forward, so a default that the new chart changed may never reach you. The most reliable habit is a values file: keep your order form in a file and pass it with `-f` every time.

## Version skew: fit the station to the solar system

Skew means two things are different versions. Here the two things are Kyverno and Kubernetes. A chart states the Kubernetes versions it accepts, and each Kyverno release note lists the Kubernetes versions that version supports. Read the limit from the chart:

```sh
helm show chart kyverno/kyverno | grep kubeVersion
```

The line shows a version range, for example a minimum Kubernetes version. Helm refuses to install a chart on a cluster outside that range. The release notes may be stricter than the chart, so read both. If you plan to upgrade Kubernetes too, check that the new Kubernetes version is supported by your Kyverno version before you upgrade Kubernetes.

## Read release notes for breaking changes

Release notes are the bulletin that comes with each station model. Read the notes for every minor version between your version and your target. Look for these words: breaking, removed, deprecated, renamed, changed default, migration. A changed default can change behaviour with no error. For example, the chart's own change log for a version may say that a flag is now on by default.

## The pre-upgrade checklist

Run these steps in order. Each has a command you can run.

1. Read the release notes for every version you skip.
2. Check the chart's Kubernetes limit: `helm show chart kyverno/kyverno | grep kubeVersion`.
3. Back up policies and exceptions to files with `kubectl get clusterpolicies.kyverno.io,policies.kyverno.io,policyexceptions.kyverno.io -A -o yaml`.
4. Save the current values: `helm get values kyverno -n kyverno -o yaml > values-before.yaml`.
5. Note the current revision with `helm history kyverno -n kyverno`. That is your way back.
6. Upgrade with a values file, or with `--reuse-values`, and with `--wait` and `--timeout`.
7. Check `helm status`, `helm history`, the four rollouts and the Pods.
8. If a check fails, roll back with `helm rollback kyverno <revision> -n kyverno --wait`.

## Common pitfalls

> [!WARNING]
> - **Using `--reset-values` by accident.** Every setting you did not retype goes back to the default. Read `helm get values` after the upgrade.
> - **Trusting `--reuse-values` across chart versions.** It can freeze old defaults. Prefer a values file.
> - **Ignoring the Kubernetes limit.** A chart outside the range will not install, and a cluster upgrade can leave Kyverno unsupported.
> - **Upgrading without a way back.** Note the working revision number first.
