# Overview: Webhooks, Failure Policy and Certificates (Playground)

This playground starts a fresh Kubernetes cluster with Kyverno already installed. There is no grading. Use it to read the webhook configurations that Kyverno writes, to change how they behave through Helm values and to look at the certificates behind them.

## What's in the box

The single-node kind cluster runs Kubernetes 1.35.8. The release `kyverno` is installed at default values in the `kyverno` namespace. A namespace named `mission-ops` exists. The ClusterPolicy `audit-owner-label` matches Pods and runs in Audit mode.

| Object | What it is |
| --- | --- |
| Webhook configurations whose names start with `kyverno-` | The doors that the API server uses to call the admission controller. Kyverno creates and updates them at runtime |
| Secret `kyverno-svc.kyverno.svc.kyverno-tls-ca` | The certificate authority of the admission controller |
| Secret `kyverno-svc.kyverno.svc.kyverno-tls-pair` | The certificate and key of the admission controller |
| ClusterPolicy `audit-owner-label` | A rule that makes Kyverno register a Pod webhook |

## Helpers

`show_hooks` lists the Kyverno webhook configurations. `hook_policies` prints the failure policy of every webhook in one configuration. `cert_dates` prints the validity dates of the admission certificate.

```sh
show_hooks() {
  kubectl get validatingwebhookconfigurations,mutatingwebhookconfigurations | grep -i "NAME\|kyverno"
}

hook_policies() {
  kubectl get validatingwebhookconfiguration "$1" \
    -o jsonpath='{range .webhooks[*]}{.name}{"  "}{.failurePolicy}{"  "}{.timeoutSeconds}{"\n"}{end}'
}

cert_dates() {
  kubectl get secret kyverno-svc.kyverno.svc.kyverno-tls-pair -n kyverno \
    -o jsonpath='{.data.tls\.crt}' | base64 -d | openssl x509 -noout -subject -startdate -enddate -serial
}
```

## Practice tasks

- Run `show_hooks`, then `hook_policies kyverno-resource-validating-webhook-cfg`. Write down the failure policy and the timeout of each webhook.
- Read the namespace selector of the same configuration with `kubectl get validatingwebhookconfiguration kyverno-resource-validating-webhook-cfg -o jsonpath='{.webhooks[*].namespaceSelector}'`.
- Set `features.forceFailurePolicyIgnore.enabled=true` with `helm upgrade --reuse-values`, wait for the admission controller, and run `hook_policies` again.
- Add `mission-ops` to `config.webhooks.namespaceSelector` (keep `kube-system`), upgrade, and watch the selector in the live webhook configuration change.
- Run `cert_dates`. Delete the secret `kyverno-svc.kyverno.svc.kyverno-tls-pair`, wait a few seconds and run `cert_dates` again. Compare the serial numbers.
- Render the chart with `helm template kyverno kyverno/kyverno -n kyverno --set admissionController.createSelfSignedCert=true` and find out which Secret objects appear.
- Set `admissionController.container.extraArgs.webhookTimeout=20` and find the flag in the admission controller Deployment.
