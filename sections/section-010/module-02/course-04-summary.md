# Summary

Well flown, astronaut. You built Kyverno from a parts list, took it apart again and learned to check the orbit for debris. This page recaps each part, lists your mission, lets you check yourself and ends with cleaning up.

## What you learned

**[Installing from the Release Manifest](./course-01-installing-from-the-release-manifest.md):**

- Every release publishes one `install.yaml`. Write the version into the address: `.../releases/download/v1.19.2/install.yaml`.
- `kubectl create` makes new objects and stops with `AlreadyExists` if one exists. Plain `kubectl apply` stores the whole file in an annotation, and some Kyverno custom resource definitions are too large for it. Use `kubectl create`, or `kubectl apply --server-side`.
- A manifest install gives no Helm release, no values and no `helm history`, and the file holds no cleanup jobs and no webhook configurations.

**[Uninstalling Kyverno and Cleaning Up](./course-02-uninstalling-and-cleaning-up.md):**

- `helm uninstall kyverno -n kyverno` removes the objects the release made. This chart also runs two pre-delete jobs that remove webhook configurations. Check them with `helm template`.
- Look for leftovers: webhook configurations with `kyverno` in the name, custom resource definitions ending in `kyverno.io`, and the `kyverno` namespace with its kept ConfigMap.
- Clean up in order: webhook configurations, then definitions (they take every policy with them, so back up first), then the namespace.
- A manifest install is removed with `kubectl delete -f` on the same file, followed by the same checks.

**[Choosing Helm or the Manifest](./course-03-choosing-helm-or-the-manifest.md):**

- Helm gives a release record, values, rollback and cleanup hooks. The manifest needs only `kubectl`.
- `helm list -n kyverno` and the `app.kubernetes.io/managed-by` label tell you which method a cluster used.
- Never mix the two methods on one install.

## Your missions

You proved these skills in a graded mission:

| Mission | After the part | What you proved |
| --- | --- | --- |
| [Remove Kyverno Cleanly](./labs/lab-01/README.md) | Uninstalling Kyverno and Cleaning Up | remove the release and every leftover webhook configuration, definition and namespace, then create a Pod |

If you skipped it, go back to it now.

## Check yourself

Try to answer each question before you open the answer.

<details>
<summary>1. Why is <code>kubectl create</code> the usual way to install the manifest?</summary>

It stops on an existing object, and it does not store a copy of each object in an annotation. Plain `kubectl apply` can fail on the largest custom resource definitions. `kubectl apply --server-side` is the other safe way.
</details>

<details>
<summary>2. After a manifest install, what does <code>helm list -n kyverno</code> show?</summary>

Nothing. No Helm release was ever written, so there are no values and no history either.
</details>

<details>
<summary>3. <code>helm uninstall</code> finished without errors. What do you still check?</summary>

Webhook configurations with `kyverno` in the name, custom resource definitions ending in `kyverno.io`, and the `kyverno` namespace.
</details>

<details>
<summary>4. In what order do you remove the leftovers, and why?</summary>

Webhook configurations first, so the API server stops calling a service that is gone. Then the definitions. Then the namespace.
</details>

<details>
<summary>5. What happens to your <code>ClusterPolicy</code> objects when you delete the <code>clusterpolicies.kyverno.io</code> definition?</summary>

They are deleted with it. Save a copy first with `kubectl get clusterpolicy -o yaml`.
</details>

<details>
<summary>6. You inherit a cluster. How do you tell if Kyverno was installed with Helm?</summary>

Run `helm list -n kyverno`, and read the `app.kubernetes.io/managed-by` label on the Deployments in the namespace. A Helm install shows a release and the value `Helm`.
</details>

## Clean up

The playground and the mission each run their own cluster on your machine. When you are done with this module, check that none is still running.

First, see what is still running:

```sh
astrona list
```

If something from this module is still listed, remove it by its **name**, not its folder path:

```sh
astrona destroy ats-008-lab-013
astrona destroy ats-008-playground-010-02
```

Run `astrona list` again to check that everything is gone.

> *Build by the book, take apart by the checklist, and always look for debris in orbit.*

<!-- astrona:playground:destroy -->
