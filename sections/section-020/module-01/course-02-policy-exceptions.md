# Policy Exceptions

Sometimes a rule book is right for almost every ship and wrong for one. A legacy ship in the middle of a refit may not carry the required label yet. You could edit the rule book, but then the book fills up with special cases. A `PolicyException` is a signed waiver instead: it lets one named ship skip one named rule, and the rule book stays clean.

## The waiver is off by default

A `PolicyException` is a form you can always file with the registry desk. But on a default install, no inspector reads it. The admission controller (the inspectors at the launch gate) ignores waivers until you switch the feature on with two flags:

- `--enablePolicyException=true` turns waiver checking on.
- `--exceptionNamespace=<planet>` names the one planet that is allowed to issue waivers. A waiver filed on any other planet is ignored.

The second flag keeps waiver power in the hands of one trusted team. On Kyverno v1.13.2 both flags go on the `kyverno-admission-controller` Deployment.

## See it in your playground

First look at the playground rule book at work. Start with a Pod that has no `owner` label. The `ClusterPolicy` should turn it away.

<!-- astrona:playground:renew -->

```sh
kubectl run smoke-test --image=nginx:alpine -n checkout
```

The registry desk should refuse the launch and quote the message from `require-owner-label`. No Pod is created.

Now read the dials on the admission controller:

```sh
kubectl get deployment kyverno-admission-controller -n kyverno -o jsonpath='{.spec.template.spec.containers[0].args}'
```

Look for `--enablePolicyException`. On this install it is not set to `true`, so waivers would be ignored.

## Switch the waiver feature on

Add both flags to the live Deployment and wait for the inspectors to restart:

```sh
kubectl patch deployment kyverno-admission-controller -n kyverno --type=json \
  -p='[{"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--enablePolicyException=true"},
       {"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--exceptionNamespace=checkout"}]'
kubectl rollout status deployment/kyverno-admission-controller -n kyverno --timeout=180s
```

The patch appends two entries to the container's `args` list, and the rollout waits until the new inspectors are ready. A patch on a live Deployment is fast, but a later Helm upgrade can overwrite it. A Helm install would set the same flags under `admissionController.container.extraArgs`.

## Write the waiver

Save this as `except-checkout-smoke-test.yaml`:

```yaml
apiVersion: kyverno.io/v2
kind: PolicyException
metadata:
  name: except-checkout-smoke-test
  namespace: checkout
spec:
  exceptions:
    - policyName: require-owner-label
      ruleNames:
        - check-owner-label
  match:
    any:
      - resources:
          kinds:
            - Pod
          names:
            - smoke-test
          namespaces:
            - checkout
```

Read it from the top. `exceptions` names the policy and the rule to skip. `match` names who may skip it: here, one Pod called `smoke-test` on the `checkout` planet. The waiver itself lives on `checkout`, the planet that `--exceptionNamespace` trusts.

Apply it:

```sh
kubectl apply -f except-checkout-smoke-test.yaml
```

## Prove the waiver, and prove it is narrow

Launch the same Pod again. This time the waiver should let it through:

```sh
kubectl run smoke-test --image=nginx:alpine -n checkout
```

Then launch a second Pod with no label and a different name:

```sh
kubectl run no-owner-pod --image=nginx:alpine -n checkout
```

The second launch should be refused. The waiver names `smoke-test` only, so every other ship is still inspected. Check the report cards on the planet:

```sh
kubectl get policyreport -n checkout
```

Reports can take a short time to appear. Run the command again after a moment if the list is empty.

## Common pitfalls

> [!WARNING]
> - **Filing a waiver and expecting it to work.** Without `--enablePolicyException=true` the waiver is silently ignored. Read the live `args` first.
> - **Filing the waiver on the wrong planet.** A waiver outside the `--exceptionNamespace` planet is ignored, just as if the feature were off.
> - **Using an `apiVersion` from another release.** On v1.13.2 the form is `kyverno.io/v2`. Check the served versions with `kubectl get crd policyexceptions.kyverno.io -o jsonpath='{.spec.versions[*].name}'`.
> - **A waiver that names the wrong rule.** `policyName` and `ruleNames` must match the real policy and rule exactly. A typo means the Pod is still refused.

## Your mission: PolicyException CRD Lab

You can now switch waivers on, write one that exempts a single Pod and prove that another Pod is still turned away. The mission starts a fresh solar system, with the same planet and rule book, and asks you to do it again and then check the report cards.

Pause your playground first:

```sh
astrona stop ats-008-playground-020-01
```

Start the mission, then grade it when you are done:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS008.git -c sections/section-020/module-01/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS008.git -c sections/section-020/module-01/labs/lab-01
```

When you have finished, remove the mission and bring your playground back:

```sh
astrona destroy ats-008-lab-003
astrona start ats-008-playground-020-01
```
