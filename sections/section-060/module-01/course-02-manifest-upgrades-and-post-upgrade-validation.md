# Manifest Upgrades and Post-Upgrade Validation

A station built by hand from a parts list has no flight record, so the crane cannot refit it. This part explains what that means for an install made with `install.yaml`, then gives the routine you run around every upgrade: back up before, check after.

Along the way you meet `kyverno migrate`, a command that brings old stored objects up to date.

<!-- astrona:playground:renew -->

## Manifest installs have no in-place upgrade

If you installed Kyverno with `kubectl create -f` and the release's `install.yaml`, you did not make a Helm release. Helm has no flight record for that station, so there is no `helm upgrade` for it. The documented way to move to a new version is to remove the old station and build the new one:

```sh
kubectl delete -f https://github.com/kyverno/kyverno/releases/download/vOLD/install.yaml
kubectl create -f https://github.com/kyverno/kyverno/releases/download/vNEW/install.yaml
```

Replace `vOLD` and `vNEW` with real version numbers. The controllers are gone between the two commands, so this is an outage, not a rolling refit. That is one practical reason to install with Helm.

You do not run these two commands in your playground, because it was installed with Helm. Use the idea as a check: if `helm list -n kyverno` shows no release, the install came from a manifest.

## Post-upgrade migration with `kyverno migrate`

Sometimes a new Kyverno version changes the stored version of a CRD. Objects saved in the old form then need to be written again in the new form. The Kyverno command line has a command for that:

```sh
kyverno migrate --resource policyexceptions.kyverno.io
```

The release notes for your target version say whether you must run it. The Helm chart already runs the same command for you in its post-upgrade hook. For a manifest install, you run it yourself.

## Back up before you upgrade

A backup is a copy of the rule books in your own hands. If an upgrade goes wrong, you can compare against it or apply it again.

Save every policy to a file:

```sh
kubectl get clusterpolicies.kyverno.io,policies.kyverno.io -A -o yaml > policy-backup.yaml
```

The file holds each `ClusterPolicy` and each namespaced `Policy` as the cluster stores them. In your playground no policy exists yet, so the file is almost empty. To practise with real content, save this as `clusterpolicy-require-owner-label.yaml`:

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: require-owner-label
spec:
  validationFailureAction: Audit
  background: true
  rules:
    - name: check-owner-label
      match:
        any:
          - resources:
              kinds:
                - Pod
      validate:
        message: "The label 'owner' is required."
        pattern:
          metadata:
            labels:
              owner: "?*"
```

Apply it:

```sh
kubectl apply -f clusterpolicy-require-owner-label.yaml
```

Then back up again:

```sh
kubectl get clusterpolicies.kyverno.io -o yaml > policy-backup.yaml
```

### See it in your playground

Run the commands above in your playground. Open `policy-backup.yaml` and find the name `require-owner-label`. That is the evidence a backup is useful.

## Check after you upgrade

An upgrade is finished when the flight record and the ships agree. Run these after every upgrade:

```sh
helm status kyverno -n kyverno
helm history kyverno -n kyverno
kubectl rollout status deployment/kyverno-admission-controller -n kyverno
kubectl rollout status deployment/kyverno-background-controller -n kyverno
kubectl rollout status deployment/kyverno-reports-controller -n kyverno
kubectl rollout status deployment/kyverno-cleanup-controller -n kyverno
kubectl get pods -n kyverno
kubectl get crd clusterpolicies.kyverno.io
```

`helm status` shows the release state and the revision number. `helm history` shows one row per revision. The four rollout checks wait until each controller's new Pods are ready. The last two commands show that no Pod is stuck and that the policy CRD is still there.

### See it in your playground

Upgrade once more, run the checks above, then confirm that your policy did not change:

```sh
helm upgrade kyverno kyverno/kyverno -n kyverno --reuse-values --set admissionController.replicas=3
kubectl get clusterpolicy require-owner-label -o yaml
```

A policy's `spec` does not change when Kyverno is upgraded. Only the controllers that read the rule book changed. Compare the `spec` with `policy-backup.yaml`.

> [!TIP]
> `helm history` shows when each revision happened and its status. Make it the first command of every upgrade and the last one too: the row you add is your proof.

## Common pitfalls

> [!WARNING]
> - **Deleting with the wrong manifest.** Remove a manifest install with the same `install.yaml` address you built it from. A different file can leave objects behind.
> - **Skipping the backup because "the spec never changes".** An upgrade can fail half way, and you may need the exact copy.
> - **Stopping at the exit code.** `helm upgrade` can finish while new Pods still wait. Run the rollout checks.
> - **Running `kyverno migrate` without reading the notes.** Not every upgrade needs it, and the notes say which objects it covers.

## Your mission: Upgrading a Live Kyverno Release Lab

You can now upgrade a Helm release in place, read the flight record and prove the cluster stayed healthy. The mission starts a fresh cluster with Kyverno at revision 1 and asks you to upgrade the release with `--reuse-values`, set the admission controller to three replicas and check the history and the Pods.

Pause the playground first, so the lab has the memory it needs:

```sh
astrona stop ats-008-playground-060-01
```

Start the lab, then grade it when you are done:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS008.git -c sections/section-060/module-01/labs/lab-01
astrona submit -c sections/section-060/module-01/labs/lab-01
```

When you are done, remove the lab and start the playground again:

```sh
astrona destroy ats-008-lab-011
astrona start ats-008-playground-060-01
```
