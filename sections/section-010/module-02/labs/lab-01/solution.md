# Solution Walkthrough

You will look at the cluster, remove the Helm release, and then check for what is left and remove it in a safe order: webhook configurations, custom resource definitions, namespace. After each step you can run `astrona submit -c sections/section-010/module-02/labs/lab-01` to see which checks already pass. The checks that look at things you have not removed yet fail, and that is expected.

---

## Step 1: Look at the cluster first

```sh
helm list -A --all
kubectl get clusterpolicy
kubectl get validatingwebhookconfigurations,mutatingwebhookconfigurations
kubectl get crd -o name | grep 'kyverno.io$'
```

You see the release `kyverno`, the policy `require-owner-label`, webhook configurations with `kyverno` in the name and the Kyverno custom resource definitions. Run `astrona submit` now. All five checks fail.

---

## Step 2: Uninstall the release

```sh
helm uninstall kyverno -n kyverno
```

Helm runs its cleanup jobs before it deletes the objects, so this can take a minute. Run `astrona submit`: the release check passes.

---

## Step 3: Check what is left

```sh
helm list -A --all
kubectl get validatingwebhookconfigurations,mutatingwebhookconfigurations
kubectl get crd -o name | grep 'kyverno.io$'
kubectl get namespace kyverno
```

Do not assume what Helm removed. Read each list. Anything with `kyverno` in the name of a webhook configuration, anything ending in `kyverno.io` in the definitions, and the `kyverno` namespace are leftovers, if they are still listed.

---

## Step 4: Remove leftover webhook configurations

Do this before anything else, so the API server stops calling a service that is gone. If the lists in the last step were empty, the loops do nothing.

```sh
for name in $(kubectl get validatingwebhookconfigurations -o name | grep kyverno); do kubectl delete "$name"; done
for name in $(kubectl get mutatingwebhookconfigurations -o name | grep kyverno); do kubectl delete "$name"; done
```

Run `astrona submit`: the webhook check passes.

---

## Step 5: Remove leftover custom resource definitions

```sh
for crd in $(kubectl get crd -o name | grep 'kyverno.io$'); do kubectl delete "$crd"; done
```

Deleting a definition also deletes every custom resource of that kind. Run `astrona submit`: the definition check passes.

---

## Step 6: Remove the namespace

```sh
kubectl delete namespace kyverno
```

The command waits until the namespace is gone. Run `astrona submit`: the namespace check passes.

---

## Step 7: Create an ordinary Pod

```sh
kubectl run owner-check -n default --image=registry.k8s.io/pause:3.9 --restart=Never
kubectl delete pod owner-check -n default
```

The Pod has no `owner` label, and the request is accepted, because no policy and no webhook is left to refuse it.

---

## Step 8: Verify Your Configuration

Run the full grading with `astrona submit -c sections/section-010/module-02/labs/lab-01`. All five checks should pass.
