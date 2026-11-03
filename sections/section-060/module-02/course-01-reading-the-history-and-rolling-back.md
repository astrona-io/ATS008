# Reading the History and Rolling Back

An upgrade can finish with a happy message and still leave ships that cannot start. In your playground that has already happened. This part shows how to see it, and how to return to the revision that worked.

<!-- astrona:playground:renew -->

## See the broken refit

Start with the flight record and the ships. The first command lists every revision of the release `kyverno`, and the second lists the Pods in the `kyverno` namespace:

```sh
helm history kyverno -n kyverno
kubectl get pods -n kyverno
```

The history has two rows. Both revision 1 and revision 2 look fine as records: revision 2 is marked `deployed`. In the Pod list, find a `kyverno-admission-controller` Pod that shows `ErrImagePull` or `ImagePullBackOff`. That is the new inspector that cannot find its ship image.

### Why Helm said "deployed"

Helm records an upgrade when it has sent the new objects to the API server. It only waits for the Pods when you ask it to, with `--wait` (and `--timeout` for how long). The bad upgrade did not ask. So the record says `deployed`, while the Deployment's rolling update is stuck.

Kubernetes did the second half of the work. The Deployment keeps the old Pod running and starts one new Pod, because the update strategy allows one extra Pod and no missing one. That is why admission may still work while the release is broken.

Helm 4 also has `--rollback-on-failure`, which rolls an upgrade back by itself if it fails and turns waiting on. In Helm 3 the flag with the same job is called `--atomic`.

### Read what revision 2 asked for

Every revision stores the values you gave it. Read them for revision 2:

```sh
helm get values kyverno -n kyverno --revision 2
```

You should find a value that sets the admission controller image tag to `v0.0.0-does-not-exist`. That one line is the whole mistake.

## Roll back to a good revision

`helm rollback` takes the release name and a revision number. It re-applies what that revision contained:

```sh
helm rollback kyverno 1 -n kyverno --wait --timeout 5m
```

If you leave out the number, or give 0, Helm goes back to the previous revision. With `--wait`, the command waits until the Pods are ready, up to the timeout. You can try a rollback first with `--dry-run`, which simulates it without saving anything.

Now read the record again. The `--show-rollback-revision` flag adds a column that names the revision you returned to:

```sh
helm history kyverno -n kyverno --show-rollback-revision
helm status kyverno -n kyverno
```

You now see three rows. The rollback did not delete revision 2. It added revision 3, which holds the contents of revision 1 and has a description that says it was a rollback. Revision 3 is `deployed` and revision 2 is `superseded`. `helm status` shows the release state and the current revision number.

Last, check the ships. Do not trust the record alone:

```sh
kubectl rollout status deployment/kyverno-admission-controller -n kyverno --timeout=180s
kubectl get pods -n kyverno
```

The admission controller Pods are `Running`, and no Pod shows an image pull error. A finished hook Job Pod may show `Completed`. That is normal.

> [!TIP]
> Run `helm history` first when anything looks wrong after an upgrade. Look at the revision numbers, the status of each and the descriptions. It tells you which revision to return to before you touch anything.

## Common pitfalls

> [!WARNING]
> - **Believing "deployed".** Without `--wait`, Helm marks an upgrade deployed while Pods fail. Check the Pods.
> - **Expecting revision 2 to disappear.** A rollback adds a new revision. The history grows.
> - **Rolling back to a revision that is gone.** Helm keeps only the last 10 revisions by default (`--history-max`), so very old revisions may not exist.
> - **Fixing the Pod instead of the release.** Deleting the broken Pod by hand does not change the release. The next rollout brings the same mistake back.

## Your mission: Rolling Back a Bad Kyverno Upgrade Lab

You can now read the flight record, find a revision that Helm called deployed but the ships could not run, and return to the revision that worked. The mission starts a fresh cluster with a broken revision 2 and asks you to roll the release back to revision 1 and prove that the admission controller is healthy and that the history shows the rollback.

Pause the playground first, so the lab has the memory it needs:

```sh
astrona stop ats-008-playground-060-02
```

Start the lab, then grade it when you are done:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS008.git -c sections/section-060/module-02/labs/lab-01
astrona submit -c sections/section-060/module-02/labs/lab-01
```

When you are done, remove the lab and start the playground again:

```sh
astrona destroy ats-008-lab-020
astrona start ats-008-playground-060-02
```
