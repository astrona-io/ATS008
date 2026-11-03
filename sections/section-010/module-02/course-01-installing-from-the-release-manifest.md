# Installing from the Release Manifest

Astronaut, a Helm install is a station built by a shipyard crane from a kit, with a flight record. The manifest install is the same station built by hand from a parts list. This part shows how to read that list, how to install from it safely, and what you give up when you skip Helm.

## The release file

Each Kyverno release publishes one file named `install.yaml` next to the release. It holds every object Kyverno needs in one place: the `kyverno` namespace, the custom resource definitions, the four controller Deployments, their Services, service accounts and permissions. The address has the version in it:

```text
https://github.com/kyverno/kyverno/releases/download/v1.19.2/install.yaml
```

The part `v1.19.2` is the Kyverno version. Always write a version into the address and never rely on a "latest" address, so that two clusters built a month apart get the same station. When you upgrade, you change that one word on purpose.

### See it in your playground

Your playground already runs Kyverno, installed with Helm, so do not install the file there. Download it and read it instead. This only reads a file:

<!-- astrona:playground:renew -->

```sh
curl -sL https://github.com/kyverno/kyverno/releases/download/v1.19.2/install.yaml -o install.yaml
grep -c '^kind: CustomResourceDefinition' install.yaml
grep -E '^kind: (Job|ValidatingWebhookConfiguration|MutatingWebhookConfiguration)' install.yaml
```

The first `grep` counts the custom resource definitions (a custom resource definition teaches mission control's registry a new kind of form, such as `ClusterPolicy`). The second finds no lines at all: the file holds no Job and no webhook configuration. Keep that in mind, because it matters when you remove Kyverno.

## Installing: `kubectl create`

Kyverno's instructions use `kubectl create`, with the version pinned in the address:

```sh
kubectl create -f https://github.com/kyverno/kyverno/releases/download/v1.19.2/install.yaml
```

Then wait for the four controllers, as a Helm install would:

```sh
kubectl -n kyverno rollout status deployment/kyverno-admission-controller --timeout=180s
```

Repeat the check for `kyverno-background-controller`, `kyverno-reports-controller` and `kyverno-cleanup-controller`. A script can do it in a loop over the four names.

## `kubectl create` against `kubectl apply`

Both commands send objects to the Kubernetes API server, mission control's registry desk. They differ in what they do when an object already exists, and in what they write down.

`kubectl create` only makes new objects. If an object exists, it stops with an `AlreadyExists` error. That is useful for a first install: you learn at once that something is already there.

`kubectl apply` makes the object when it is missing and merges your file into it when it exists. To work out later changes, the plain form of `apply` stores a full copy of your file in an annotation on the object, called `kubectl.kubernetes.io/last-applied-configuration`. An annotation may hold at most 262144 bytes. Some of Kyverno's custom resource definitions are larger than that, so a plain `kubectl apply -f install.yaml` can fail with an error about an annotation that is too long.

There are two safe ways around it. Use `kubectl create` for the first install, as Kyverno does. Or use server-side apply, which keeps its bookkeeping inside the API server and writes no such annotation:

```sh
kubectl apply --server-side -f https://github.com/kyverno/kyverno/releases/download/v1.19.2/install.yaml
```

Server-side apply is also the right tool when you repeat the install from a newer file.

### See it in your playground

See the "create" safety net at work. Ask the API server to create the whole file against your playground, where Kyverno already exists. The `--dry-run=server` flag asks the API server to check the request without saving anything:

```sh
kubectl create -f install.yaml --dry-run=server
```

Look for `AlreadyExists` errors for objects such as the `kyverno` namespace and the custom resource definitions. Nothing is changed.

## What a manifest install does not give you

The manifest gives you every object, and nothing around them. Three things that Helm kept for you are missing.

### No release record

Helm writes a release with its own name and a flight record of revisions. A manifest install writes none. After a manifest install, `helm list -n kyverno` shows nothing, because Helm never heard of the station. There is no `helm history` and no `helm rollback` either.

### No values

With Helm, your choices live in a values file, and `helm get values -a` reads them back. The manifest has no order form. To change a setting you edit the file and apply it again, or you patch a live object. A patch lives only in the cluster, so a later re-install from the file quietly throws it away.

### No cleanup hooks

A Helm chart can run small jobs when the release is removed. The file has no such jobs (you saw that the search for a Job found nothing). Whatever the controllers created by themselves while running is not in the file, so deleting the file's objects does not remove it. The next part shows which objects that means.

You can see how a cluster was built by looking at the labels that Helm adds to the objects it makes:

```sh
grep -c 'managed-by: Helm' install.yaml
kubectl get deploy kyverno-admission-controller -n kyverno -o jsonpath='{.metadata.labels.app\.kubernetes\.io/managed-by}'
```

The count for the file is `0`. The label on your playground's Deployment says `Helm`, because the playground was built with Helm.

> [!TIP]
> Write the version into the address and put the command in a script or a pipeline step. Then your install is a reviewable change, even though the manifest has no flight record of its own.

## Common pitfalls

> [!WARNING]
> - **Using a "latest" address.** Two installs from different days can differ. Pin the version in the address.
> - **Running plain `kubectl apply -f install.yaml`.** A large custom resource definition can make it fail on the annotation size. Use `kubectl create`, or `kubectl apply --server-side`.
> - **Expecting `helm list` to show a manifest install.** It will not. No release was ever written.
> - **Installing the file over a Helm install.** The objects already exist, so `kubectl create` stops with `AlreadyExists`. Remove the old install first, then install once with one method.
