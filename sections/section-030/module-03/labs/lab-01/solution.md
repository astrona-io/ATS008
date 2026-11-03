# Solution Walkthrough

You change two groups of settings with Helm and replace one secret. Run `astrona submit` after each step to see which checks pass.

## Step 1: Write the values file

Save this as `webhook-values.yaml`:

```yaml
config:
  webhooks:
    namespaceSelector:
      matchExpressions:
        - key: kubernetes.io/metadata.name
          operator: NotIn
          values:
            - kube-system
            - mission-ops
features:
  forceFailurePolicyIgnore:
    enabled: true
```

The selector replaces the default one, so `kube-system` must be written again. The chart adds the exclusion of the `kyverno` namespace on its own. `forceFailurePolicyIgnore` makes the admission controller start with `--forceFailurePolicyIgnore=true`.

## Step 2: Apply the upgrade

```sh
helm upgrade --reuse-values -n kyverno kyverno kyverno/kyverno -f webhook-values.yaml
kubectl rollout status deployment/kyverno-admission-controller -n kyverno
```

Run `astrona submit -c sections/section-030/module-03/labs/lab-01`. The checks `webhook-selector`, `failure-policy` and `changes-made-with-helm` should pass. The webhook configurations are rewritten by the admission controller a few seconds after it starts, and the grader waits for this.

## Step 3: Replace the certificate

Delete the secret that holds the certificate. Kyverno notices and issues a new one:

```sh
kubectl delete secret kyverno-svc.kyverno.svc.kyverno-tls-pair -n kyverno
```

Wait until the secret is back:

```sh
kubectl get secret kyverno-svc.kyverno.svc.kyverno-tls-pair -n kyverno
```

Run `astrona submit` again. The `certificate` check passes when the serial number differs from the starting one.

## Step 4: Verify your configuration

```sh
kubectl get validatingwebhookconfiguration kyverno-resource-validating-webhook-cfg \
  -o jsonpath='{.webhooks[*].failurePolicy}{"\n"}{.webhooks[*].namespaceSelector}{"\n"}'
kubectl get secret kyverno-svc.kyverno.svc.kyverno-tls-pair -n kyverno \
  -o jsonpath='{.data.tls\.crt}' | base64 -d | openssl x509 -noout -serial -enddate
kubectl get pods -n kyverno
```

The first command lists only `Ignore` and a selector with `mission-ops`. The second prints the new serial and the end date. The Pods should all be ready.
