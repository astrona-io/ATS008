# Audit and Enforce, and the Report Kinds

When a rule book finds a ship that breaks a rule, it can do one of two things. It can turn the ship away at the gate (`Enforce`), or it can let the ship through and write the problem on a report card (`Audit`). This part shows both in your playground and then shows where the report cards live.

## Audit and Enforce

The setting is `failureAction` on the `validate` part of each rule. The old place, `validationFailureAction` at the top of the policy, still exists but the chart's CRD marks it as deprecated. Read the setting on your playground policy:

<!-- astrona:playground:renew -->

```sh
kubectl get clusterpolicy require-crew-labels -o jsonpath='{.spec.rules[*].validate.failureAction}'
```

Both rules should print `Audit`. In `Audit` mode a request that breaks the rule is accepted, and the problem is recorded. Prove it. Save this as `deployment-rogue.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: rogue
  namespace: hangar
spec:
  replicas: 1
  selector:
    matchLabels:
      app: rogue
  template:
    metadata:
      labels:
        app: rogue
    spec:
      containers:
        - name: pause
          image: registry.k8s.io/pause:3.10
```

Apply it:

```sh
kubectl apply -f deployment-rogue.yaml
```

The Deployment has no `owner` and no `team` label, but the registry desk accepts it. Kyverno recorded two failed results for it instead of blocking it.

Now switch the first rule to `Enforce` and try again:

```sh
kubectl patch clusterpolicy require-crew-labels --type=json -p='[{"op":"replace","path":"/spec/rules/0/validate/failureAction","value":"Enforce"}]'
kubectl delete deployment rogue -n hangar
kubectl apply -f deployment-rogue.yaml
```

The new launch should be refused with the message of the rule. A blocked launch never becomes an object, so there is nothing to put on a report card for it. Put the rule back to `Audit` when you finish:

```sh
kubectl patch clusterpolicy require-crew-labels --type=json -p='[{"op":"replace","path":"/spec/rules/0/validate/failureAction","value":"Audit"}]'
```

## The report kinds

Kyverno files two kinds of report card, both in the API group `wgpolicyk8s.io`:

| Kind | Scope | Holds results for |
| --- | --- | --- |
| `PolicyReport` | One planet (a namespace) | Namespaced objects such as Deployments and Pods |
| `ClusterPolicyReport` | The whole solar system | Cluster-scoped objects such as Namespaces and Nodes |

Each report card is about one checked object, and its `scope` field names that object. The report is owned by the object, so Kubernetes deletes the report when the object is deleted. Short names are `polr` and `cpolr`.

## Common pitfalls

> [!WARNING]
> - **Expecting `Audit` to block.** It records and lets the request through. Only `Enforce` blocks.
> - **Looking for results of a blocked request.** A refused launch creates no object, so the report holds nothing about it. Reports describe objects that exist.
> - **Looking for a namespace's result in `PolicyReport`.** A Namespace is cluster-scoped. Its results are in `ClusterPolicyReport`.
> - **Leaving a rule on `Enforce` after a test.** Put it back, or later launches in the playground will fail.
