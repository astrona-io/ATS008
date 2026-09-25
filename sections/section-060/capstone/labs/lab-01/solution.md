# Solution Walkthrough

Follow these steps for the full backup-upgrade-verify flow:

---

## Step 1: Back Up Existing Policies

```sh
kubectl get clusterpolicy -o yaml > ~/policy-backup.yaml
grep -q "require-cost-center-label" ~/policy-backup.yaml && echo "backup contains the policy"
```

Do this *before* touching the Helm release — it's your safety net if anything about the upgrade goes wrong.

---

## Step 2: Upgrade Kyverno

```sh
helm upgrade kyverno kyverno/kyverno -n kyverno \
  --reuse-values \
  --set admissionController.replicas=3 \
  --set backgroundController.extraArgs[0]=--genWorkers=15
```

`--reuse-values` keeps everything from the baseline install; only the two flags above change.

---

## Step 3: Confirm the Policy Survived Untouched

```sh
kubectl get clusterpolicy require-cost-center-label -o yaml
```

Compare this against `~/policy-backup.yaml` — the `spec` should be byte-for-byte identical to what was backed up in Step 1. A Kyverno version/config upgrade never alters an existing policy's `spec`.

---

## Step 4: Confirm the Backup File

```sh
cat ~/policy-backup.yaml | grep require-cost-center-label
```

---

## Step 5: Confirm the Upgrade Revision & New Settings

```sh
helm history kyverno -n kyverno
kubectl get deploy kyverno-admission-controller -n kyverno -o jsonpath='{.spec.replicas}'
kubectl get deploy kyverno-background-controller -n kyverno -o jsonpath='{.spec.template.spec.containers[0].args}'
```

Expect at least 2 revisions in the history, `3` admission replicas, and `--genWorkers=15` present in the background controller's args.

---

## Step 6: Verify Your Configuration

Once all five checks above pass, run the local validation suite to pass the lab!
