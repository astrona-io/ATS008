# Choosing which launches use the webhooks

Not every launch needs to ring the bell. Kyverno lets you choose which namespaces and which objects go through the doors, and how long the desk waits for each answer. This part shows the selectors in `config.webhooks`, the rule that a list you set replaces the default list, and the webhook timeout.

## Selectors: who may use the door

A webhook door has two selectors. The `namespaceSelector` picks launches by the label of their namespace. The `objectSelector` picks launches by the labels of the object itself. A launch that does not match is never sent to Kyverno, so no policy applies to it, and it does not wait for an answer either.

In the Helm chart both selectors live under `config.webhooks`, and they end up in the `webhooks` key of the ConfigMap `kyverno`. The admission controller reads the key and copies the selectors into every door it writes. The default has one rule: the namespace `kube-system` is skipped. The chart adds a second rule for the `kyverno` namespace on its own, because `config.excludeKyvernoNamespace` is `true`.

### Keep what you need

The selector is a list of match expressions. A list that you set replaces the default list. If you want to skip `mission-ops` and still skip `kube-system`, write both names. If you write only `mission-ops`, the namespace `kube-system` goes through the doors again.

Save this as `selector-values.yaml`:

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
```

The label `kubernetes.io/metadata.name` is put on every namespace by Kubernetes. It holds the namespace's own name.

### Object selectors

The `objectSelector` works the same way, but on labels of the launch itself. A common pattern is to skip every object that carries a label, for example `webhooks.kyverno.io/exclude`. You then label an object to exclude it. The chart has this as a commented example in its values.

### Skipping versus excluding

The selectors and the exclude lists in the ConfigMap do different jobs. The selectors keep a launch away from the door. The exclude lists and the resource filters let a launch reach the crew, and then the crew skips it. The selectors are cheaper, because no call is made, and they are applied by the API server, not by Kyverno.

## The call timeout

The desk waits for an answer for a limited time. For Kyverno's own doors this is the flag `--webhookTimeout`, in seconds. A slow call makes every launch that matches wait, so a long timeout slows the whole cluster when the crew is slow. A short timeout fails fast, and then the failure policy decides what happens. The API server allows a timeout of at most 30 seconds.

In the chart you set the flag with `extraArgs` on the admission container:

```yaml
admissionController:
  container:
    extraArgs:
      webhookTimeout: 20
```

A single policy can choose its own timeout with `webhookConfiguration.timeoutSeconds`, as you saw in the policy from the first part.

## See it in your playground

<!-- astrona:playground:renew -->

Read the selector that Kyverno wrote into the ConfigMap, and the one that the live door holds:

```sh
kubectl get configmap kyverno -n kyverno -o jsonpath='{.data.webhooks}'; echo
kubectl get validatingwebhookconfiguration kyverno-resource-validating-webhook-cfg \
  -o jsonpath='{.webhooks[0].namespaceSelector}'; echo
```

Both show `kube-system` and `kyverno`. Apply the file you saved as `selector-values.yaml`:

```sh
helm upgrade --reuse-values -n kyverno kyverno kyverno/kyverno -f selector-values.yaml
```

The ConfigMap changes at once. The live door changes a few seconds later, because the admission controller reads the ConfigMap and updates the doors. Run the second command above again until you see `mission-ops` in the selector. Then set a timeout with a flag:

```sh
helm upgrade --reuse-values -n kyverno kyverno kyverno/kyverno \
  --set admissionController.container.extraArgs.webhookTimeout=20
```

Wait for the new Pod, and confirm the flag and the door timeout:

```sh
kubectl rollout status deployment/kyverno-admission-controller -n kyverno
kubectl get deployment kyverno-admission-controller -n kyverno \
  -o jsonpath='{.spec.template.spec.containers[0].args}' | tr ',' '\n' | grep webhookTimeout
```

The flag change replaced the Pod, but the selector change did not. A ConfigMap change is live. A flag change is a restart.

## Common pitfalls

> [!WARNING]
> - **Writing only the new namespace in the selector.** The list replaces the default, so `kube-system` is no longer skipped. Write every namespace you want to skip.
> - **Skipping a namespace and expecting Kyverno to still protect it.** A launch that never reaches the door is never checked.
> - **Setting a very long timeout.** Each slow answer holds the launch, and the cluster feels slow. Keep the timeout short and let the failure policy decide.
> - **Expecting the door to change at once.** The ConfigMap changes first and the live door follows a few seconds later.
> - **Editing the selector on the live webhook.** The admission controller writes it again from the ConfigMap.
