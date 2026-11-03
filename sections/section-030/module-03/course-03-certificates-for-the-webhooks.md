# Certificates for the webhooks

The API server only talks to a door over TLS, and it only trusts a door whose certificate was signed by a certificate authority it knows. A certificate is an identity badge with an end date. This part shows where Kyverno keeps its badge, how it renews it, the two other ways to manage it, and how to replace it.

## Two secrets hold the badge

The admission controller keeps its TLS material in two Secret objects in the `kyverno` namespace:

| Secret | What it holds |
| --- | --- |
| `kyverno-svc.kyverno.svc.kyverno-tls-ca` | The certificate authority: the stamp that signs badges |
| `kyverno-svc.kyverno.svc.kyverno-tls-pair` | The certificate and private key that the admission controller shows to the API server |

The names come from the service name, `kyverno-svc`, and appear in the flags `--caSecretName` and `--tlsSecretName`. The cleanup controller has its own pair, named after `kyverno-cleanup-controller`. The Deployment mounts the pair, and Kyverno copies the CA into the `caBundle` field of every webhook configuration it writes. That is how the API server learns which stamp to trust.

### Reading a badge

The certificate is stored in the key `tls.crt`, in base64. You can read it with `openssl`:

```sh
kubectl get secret kyverno-svc.kyverno.svc.kyverno-tls-pair -n kyverno \
  -o jsonpath='{.data.tls\.crt}' | base64 -d | openssl x509 -noout -subject -startdate -enddate -serial
```

The command prints the subject, the start and end dates and the serial number. The serial number is unique for each badge, so a changed serial means a new badge.

## Three ways to manage the badge

The chart has three modes for the admission controller. The same values exist for the cleanup controller.

| Mode | Value | Who renews the badge |
| --- | --- | --- |
| Kyverno manages it (default) | nothing to set | Kyverno creates the secrets at start and renews them before they expire |
| Self-signed by Helm | `admissionController.createSelfSignedCert: true` | Nobody. Helm creates the secrets once, and they are not renewed |
| cert-manager | `admissionController.certManager.enabled: true` | cert-manager, which must be installed in the cluster |

The default is the right choice for most clusters. The self-signed mode is for setups where something else must create the secrets, but you must replace the badges yourself before they expire. The cert-manager mode takes precedence over `createSelfSignedCert` when both are set. The chart also has `admissionController.tlsKeyAlgorithm` (`RSA`, `ECDSA` or `Ed25519`) for the default mode.

### What happens when a badge is lost

If you delete the `tls-pair` secret in the default mode, Kyverno notices and issues a new one. The new badge has a new serial number. The admission controller picks it up, and the API server keeps trusting it, because the CA stays the same. If you delete the CA secret, Kyverno creates a new stamp, and it must write the new CA into the webhook configurations, so the doors briefly stop working. Delete the `tls-pair` secret and leave the CA alone.

## See it in your playground

<!-- astrona:playground:renew -->

Write down the serial number and the end date of the current badge:

```sh
kubectl get secret kyverno-svc.kyverno.svc.kyverno-tls-pair -n kyverno \
  -o jsonpath='{.data.tls\.crt}' | base64 -d | openssl x509 -noout -serial -enddate
```

Check which secrets the chart would create in the self-signed mode, without touching the cluster:

```sh
helm template kyverno kyverno/kyverno -n kyverno --set admissionController.createSelfSignedCert=true \
  | grep -n "kyverno-svc.kyverno.svc.kyverno-tls"
```

You should see the names of the two secrets. In the default mode the chart does not render them, because Kyverno creates them. Now replace the badge:

```sh
kubectl delete secret kyverno-svc.kyverno.svc.kyverno-tls-pair -n kyverno
```

Wait a few seconds and look for the new secret:

```sh
kubectl get secret kyverno-svc.kyverno.svc.kyverno-tls-pair -n kyverno
```

Read the badge again with the first command. The serial number is different. Finally, check that the admission controller still answers:

```sh
kubectl get pods -n kyverno
```

All Pods should be ready. The API server still trusts the badge, because the CA did not change.

## Common pitfalls

> [!WARNING]
> - **Deleting the CA secret.** Kyverno creates a new CA and rewrites the webhook configurations. The doors may fail for a short time. Delete only the `tls-pair` secret.
> - **Using `createSelfSignedCert` and forgetting the end date.** The badges are not renewed. When they expire, the doors fail and the failure policy decides what happens to launches.
> - **Turning on `certManager` without cert-manager.** The chart creates Certificate objects, and nothing issues them.
> - **Reading the dates in a different time zone.** `openssl` prints the date in GMT. Compare dates in the same zone.
> - **Printing the private key into a terminal log.** Read only `tls.crt`, never `tls.key`.

## Your mission: Webhooks, Failure Policy and Certificates Lab

You can now read the doors Kyverno builds, choose which launches use them, make them fail open and replace the badge. The mission starts a fresh cluster with Kyverno at default values, a namespace named `mission-ops` and a policy named `audit-owner-label`. It asks you to make the webhooks skip `mission-ops` while they keep skipping `kube-system`, to make them fail open, and to replace the admission controller certificate.

Pause the playground first, so the lab has the memory it needs:

```sh
astrona stop ats-008-playground-030-03
```

Start the lab, then grade it when you are done:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS008.git -c sections/section-030/module-03/labs/lab-01
astrona submit -c sections/section-030/module-03/labs/lab-01
```

When you are done, remove the lab and start the playground again:

```sh
astrona destroy ats-008-lab-017
astrona start ats-008-playground-030-03
```
