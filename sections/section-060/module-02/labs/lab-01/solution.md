# Solution Walkthrough

Follow these steps to roll the release back and prove it worked. After each step you can run `astrona submit -c sections/section-060/module-02/labs/lab-01` to see which checks pass.

---

## Step 1: Find the Broken Revision

```sh
helm history kyverno -n kyverno
kubectl get pods -n kyverno
```

The history has two rows: revision 1 (the install) and revision 2 (the upgrade). Revision 2 shows the status `deployed`, because the upgrade did not wait for the Pods. In the Pod list, look for a `kyverno-admission-controller` Pod with an image pull problem (`ErrImagePull` or `ImagePullBackOff`). The older admission controller Pod is probably still `Running`.

---

## Step 2: Roll Back to Revision 1

```sh
helm rollback kyverno 1 -n kyverno --wait --timeout 5m
```

`helm rollback` takes the release name and a revision number. It re-applies what revision 1 contained and records the result as a new revision, number 3. Revision 2 stays in the history. Leave out the number to go back to the previous revision.

---

## Step 3: Check the Flight Record

```sh
helm history kyverno -n kyverno
helm status kyverno -n kyverno
```

Expect three rows. Revision 3 is `deployed` and its description says it is a rollback to 1. Revision 2 is now `superseded`.

---

## Step 4: Check the Admission Controller

```sh
kubectl rollout status deployment/kyverno-admission-controller -n kyverno --timeout=180s
kubectl get deploy kyverno-admission-controller -n kyverno -o jsonpath='{.spec.template.spec.containers[0].image}'
kubectl get pods -n kyverno
```

The image no longer ends in `v0.0.0-does-not-exist`. The Pod list has no image pull error. A finished hook Job Pod shows `Completed`, which is fine.

---

## Step 5: Check That the Policy Still Works

```sh
kubectl get clusterpolicy require-cost-center-label
kubectl -n finance run unlabeled-test --image=busybox --dry-run=server
```

The policy is not part of the release, so the rollback did not touch it. The second command is refused with a message about the `cost-center` label. It only asks the API server to check the request and creates nothing.

---

## Step 6: Verify Your Configuration

When every check above passes, run `astrona submit -c sections/section-060/module-02/labs/lab-01` to pass the lab.
