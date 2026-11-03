# The Helm Upgrade Path

Helm is the shipyard crane, and your Kyverno release is a station it already assembled. An upgrade refits that station in orbit. This part shows the command, the one flag that stops your order form from being wiped, the habit of reading the bulletin first, and a surprise about Kyverno's custom resource definitions (CRDs).

A CRD is a new kind of form that mission control's registry learns to accept. `ClusterPolicy` is one of those forms.

<!-- astrona:playground:renew -->

## See the flight record first

Before you change anything, read the station's flight record. Each install or upgrade adds one entry, called a revision.

```sh
helm history kyverno -n kyverno
helm get values kyverno -n kyverno
```

The history shows one row: revision 1, the original install. The second command shows the values you supplied. There are none in your playground, because the install used the chart's defaults. Add `-a` to see every value in use, defaults included.

## The upgrade command

An upgrade uses the same shape as an install. It names the release, the chart and the namespace:

```sh
helm upgrade kyverno kyverno/kyverno -n kyverno --reuse-values --set admissionController.replicas=3
```

Helm sees that the release `kyverno` already exists, so it does an upgrade, not a new install. It records the result as the next revision. Helm itself did the work of writing the entry. The rolling update of the Pods is then done by Kubernetes.

Now read the flight record again and wait for the controllers:

```sh
helm history kyverno -n kyverno
kubectl rollout status deployment/kyverno-admission-controller -n kyverno --timeout=180s
```

The history now has two rows. The admission controller Deployment has three replicas.

### Why the command has `--reuse-values`

Without `--reuse-values`, Helm does not start from your last order form. It starts from the chart's defaults plus whatever you type on this command line. Any value you set in an earlier install or upgrade and do not repeat is dropped. With `--reuse-values`, Helm takes the last release's values and merges your new `--set` on top.

For a bigger change, keep your values in a file and pass it with `-f`. A file in your own repository is a better order form than your memory of old command lines.

### Pick the chart version on purpose

By default Helm uses the newest chart in the repository. To move to a chosen version, add `--version`. List what the depot has first:

```sh
helm repo update
helm search repo kyverno/kyverno --versions
```

The list shows each chart version next to the Kyverno version (the app version) it installs. Use it to see every version you would skip.

## Read the release notes for every version you skip

Release notes are the bulletin that comes with each new station model. Read the notes for the version you move to. If you skip minor versions on the way, read the notes for every minor version in between, not only the last one.

Kyverno's own upgrade guide gives an example: Kyverno 1.10 brought breaking changes that limit upgrades to that version and to later ones. A jump past 1.10 that reads only the destination's notes can miss a warning that sits in the middle.

## Kyverno's CRDs travel with the release

Many Helm charts keep their CRDs in a special `crds/` folder. Helm installs those once and never touches them again on `helm upgrade`. That is a safety rule, because deleting a CRD would delete every object built on it. For those charts you apply new CRD files by hand.

Kyverno's chart does not use that folder. Its CRDs are ordinary templates in a CRD sub-chart, switched on by the value `crds.install`, which is `true` by default. So a normal `helm upgrade` updates them. You can see them inside the release:

```sh
helm get manifest kyverno -n kyverno | grep "kind: CustomResourceDefinition"
```

Each line is one CRD that this release owns. The chart also has a post-upgrade hook, a short Job that Helm runs after an upgrade. It runs the Kyverno command line's `migrate` command on the stored objects. Look for it:

```sh
helm get hooks kyverno -n kyverno
```

Find the Job named `kyverno-migrate-resources` and its `helm.sh/hook: post-upgrade` annotation. Helm waits for hook Jobs to finish, so a hook that cannot start can make an upgrade hang.

## Common pitfalls

> [!WARNING]
> - **Forgetting `--reuse-values`.** A later `helm upgrade` with only `--set` then resets every other value to the chart default. Read `helm get values kyverno -n kyverno` afterwards.
> - **Hand-applying CRDs first.** The Kyverno chart updates its own CRDs. Do not copy that step from charts that use a `crds/` folder.
> - **Reading only the last release notes.** Breaking changes sit in the versions you skip.
> - **Trusting the exit code.** A finished `helm upgrade` shows the release was recorded. It does not show that the new Pods are ready. Check the rollout.
