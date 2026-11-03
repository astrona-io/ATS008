# Webhook configurations and failure policy

The registry desk needs to know where to ring the bell. That address list is a webhook configuration. Kyverno builds the list itself, and it keeps it up to date while the cluster runs. This part shows where the doors are, what each field means, and what happens to launches when the crew behind the door is not there.

## The doors Kyverno builds

Kubernetes has two kinds of webhook configuration object. A ValidatingWebhookConfiguration lists doors that answer yes or no. A MutatingWebhookConfiguration lists doors that may change the request. Kyverno creates several of both, and their names start with `kyverno-`.

You do not write these objects. The chart does not contain them. The admission controller creates them when it starts, and it updates them when you add, change or remove a policy. The setting that allows this is `--autoUpdateWebhooks`, which is on by default. This also means that a hand edit of a webhook configuration is lost, because the controller writes it again.

### What a door looks like

Each configuration has a list of `webhooks`. A door has the fields that matter for this module:

| Field | Meaning |
| --- | --- |
| `rules` | Which kinds and operations use this door. Kyverno fills this from your policies |
| `failurePolicy` | `Fail` or `Ignore`: what the desk does when the door gets no answer |
| `timeoutSeconds` | How long the desk waits for the answer |
| `namespaceSelector` and `objectSelector` | Which launches are sent to this door at all |
| `clientConfig` | The address of the service, and the CA certificate that the desk trusts |

Because Kyverno builds `rules` from your policies, a new policy that matches Pods adds a rule for Pods to the doors.

## Failure policy

The desk calls the door, and sometimes nobody answers. The admission controller may be starting, may be overloaded, or may be down. The failure policy decides what happens next:

- `Fail`: the desk refuses the launch. The cluster stays safe, but nothing that matches can be created until the crew is back.
- `Ignore`: the desk lets the launch through. The cluster keeps working, but the rule book was not applied.

Kyverno policies use `Fail` by default. That is the safe choice for a rule that must always hold, such as "no privileged Pods". It also means that an admission controller that is down can block launches. By default Kyverno keeps its own namespace out of the doors, so the crew can always restart itself.

### Set the failure policy of one policy

A single policy can choose its own failure policy in its `webhookConfiguration` block. Save this as `lenient-policy.yaml`:

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: audit-owner-label
spec:
  background: true
  webhookConfiguration:
    failurePolicy: Ignore
    timeoutSeconds: 5
  rules:
    - name: check-owner-label
      match:
        any:
          - resources:
              kinds:
                - Pod
      validate:
        failureAction: Audit
        message: "Pods should carry an owner label."
        pattern:
          metadata:
            labels:
              owner: "?*"
```

Use `Ignore` for rules that only advise, and keep `Fail` for rules that must hold. Kyverno keeps a separate door for each failure policy, so one lenient policy does not weaken the strict ones.

### Fail open for the whole cluster

Sometimes you want every door to fail open, for example during a risky upgrade. The admission controller has the flag `--forceFailurePolicyIgnore`. When it is on, Kyverno writes `Ignore` into every door, whatever the policies say. In the chart it is `features.forceFailurePolicyIgnore.enabled`, and it is off by default.

This is a trade-off. The cluster cannot be blocked by Kyverno, but policies that need `Fail` are no longer enforced when the crew is down. Turn it off again when the work is done.

## See it in your playground

<!-- astrona:playground:renew -->

Apply the policy you saved as `lenient-policy.yaml`:

```sh
kubectl apply -f lenient-policy.yaml
```

List the doors that Kyverno has built:

```sh
kubectl get validatingwebhookconfigurations,mutatingwebhookconfigurations | grep -i "NAME\|kyverno"
```

Print the name, failure policy and timeout of each door in the resource validating configuration:

```sh
kubectl get validatingwebhookconfiguration kyverno-resource-validating-webhook-cfg \
  -o jsonpath='{range .webhooks[*]}{.name}{"  "}{.failurePolicy}{"  "}{.timeoutSeconds}{"\n"}{end}'
```

Look at the failure policies and the timeouts. Read the flag that controls the updates:

```sh
kubectl get deployment kyverno-admission-controller -n kyverno \
  -o jsonpath='{.spec.template.spec.containers[0].args}' | tr ',' '\n' | grep -i "autoUpdate\|forceFailure"
```

The flag `--forceFailurePolicyIgnore=false` is there, because the chart always writes the flag. Now turn it on. Save this as `fail-open-values.yaml`:

```yaml
features:
  forceFailurePolicyIgnore:
    enabled: true
```

Apply it and wait for the new admission controller Pod:

```sh
helm upgrade --reuse-values -n kyverno kyverno kyverno/kyverno -f fail-open-values.yaml
kubectl rollout status deployment/kyverno-admission-controller -n kyverno
```

Run the second command again. Every door should now show `Ignore`. Kyverno wrote it by itself, a few seconds after the new Pod started.

## Common pitfalls

> [!WARNING]
> - **Editing a webhook configuration by hand.** Kyverno writes it again, so your edit is lost. Change policies or Helm values instead.
> - **Leaving `forceFailurePolicyIgnore` on.** Every policy then fails open when the crew is down, and the rules are not enforced during that time.
> - **Reading `Ignore` as "no checking".** Requests that reach the crew are still checked. `Ignore` only decides what happens when the door gets no answer.
> - **Expecting webhooks at once.** The doors appear after the admission controller has started and has seen a policy. Wait a few seconds after a change.
> - **Setting `Ignore` on a rule that must always hold.** A request that arrives while the crew is down goes through unchecked.
