# Part 1 — Policy-Authoring CRDs

> Prerequisite: [Landing page](./course.md). Next: [Part 2 — Reporting & State CRDs](./course-02-reporting-and-state-crds.md).

These are the CRDs a policy author writes YAML for directly. Kyverno's admission and background controllers watch all of them; nothing here is generated automatically.

## ClusterPolicy and Policy — a recap

`ClusterPolicy` (cluster-scoped) and `Policy` (namespace-scoped) are the two CRDs holding `spec.rules`, each rule committing to exactly one action (`validate`, `mutate`, `generate`, `verifyImages`). If this is new to you, it is covered in full depth elsewhere in the Kyverno curriculum — here we treat them only as the first two entries on the CRD map, both under `apiVersion: kyverno.io/v1`.

## PolicyException — carving out an exemption without editing the policy

Sometimes a policy is correct for 99% of the cluster and wrong for one specific workload — a CI service account, a legacy Deployment mid-migration, a debugging Pod. Editing the original `ClusterPolicy` to special-case that one resource pollutes the policy with exemption logic that has nothing to do with what the policy is actually enforcing. `PolicyException` (`apiVersion: policies.kyverno.io/v1`, namespaced) solves this as its own object:

```yaml
apiVersion: policies.kyverno.io/v1
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

This says: for the named policy's named rule, do not apply it to a Pod named `smoke-test` in `checkout`. Every other Pod in the cluster is still governed by `require-owner-label` exactly as before.

> [!WARNING]
> **`PolicyException` is disabled by default**
>
> Authoring a perfectly valid `PolicyException` object does nothing on a default Kyverno install — it is silently never evaluated. You must explicitly turn the feature on, on the admission controller itself, with two flags:
>
> - `--enablePolicyException=true` — turns on `PolicyException` evaluation at all.
> - `--exceptionNamespace=<ns>` — restricts which namespace(s) are trusted to author an exception that Kyverno will actually honor.
>
> An exception object created outside the namespace(s) named by `--exceptionNamespace` is just as inert as if the feature were off entirely. This two-flag design exists so that exception-authoring power can be handed to a narrow, trusted namespace (say, a platform team's own namespace) without opening it up cluster-wide.

> [!TIP]
> **Try it — patch a running admission controller to enable exceptions**
>
> ```sh
> kubectl set env deployment/kyverno-admission-controller -n kyverno --list 2>/dev/null || true
> kubectl patch deployment kyverno-admission-controller -n kyverno --type=json \
>   -p='[{"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--enablePolicyException=true"},
>        {"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--exceptionNamespace=checkout"}]'
> kubectl rollout status deployment/kyverno-admission-controller -n kyverno --timeout=180s
> ```
>
> A fresh Helm install would instead set these through `admissionController.container.extraArgs`, but patching a live Deployment (as above) is the fastest way to see the effect on an already-running cluster.

## CleanupPolicy and ClusterCleanupPolicy — scheduled deletion

`CleanupPolicy` (namespaced) and `ClusterCleanupPolicy` (cluster-scoped), both `apiVersion: kyverno.io/v2`, declaratively delete matching resources on a cron schedule instead of at admission time:

```yaml
apiVersion: kyverno.io/v2
kind: ClusterCleanupPolicy
metadata:
  name: clean-scaled-down-deployments
spec:
  match:
    any:
      - resources:
          kinds:
            - Deployment
          selector:
            matchLabels:
              canremove: "true"
  conditions:
    any:
      - key: "{{ target.spec.replicas }}"
        operator: LessThan
        value: 2
  schedule: "*/5 * * * *"
```

The familiar `match`/`exclude` block selects candidates; an optional `conditions` block (same condition-operator vocabulary as a `deny` block) narrows further; `schedule` is a standard cron expression the cleanup-controller evaluates. Because cleanup policies operate against resources that already exist rather than an inbound admission request, they cannot use `subjects`, `Roles`, or `ClusterRoles` in `match` — there is no "requesting identity" to match against for something that isn't a live request.

> [!WARNING]
> **Deprecation note**
>
> `CleanupPolicy`/`ClusterCleanupPolicy` is deprecated as of Kyverno v1.19 in favor of a new `DeletingPolicy` CRD, and is scheduled for removal in v1.20. It remains exam-relevant for current material and widely deployed clusters, but do not design new automation around it without checking your target version's migration notes.

## GlobalContextEntry — cache once, reuse everywhere

`GlobalContextEntry` (`apiVersion: kyverno.io/v2alpha1`, cluster-scoped) caches the result of an external `apiCall` or a watched Kubernetes resource list, on a refresh interval, so that many policies referencing the same external data do not each issue their own redundant call:

```yaml
apiVersion: kyverno.io/v2alpha1
kind: GlobalContextEntry
metadata:
  name: deployment-count
spec:
  kubernetesResource:
    group: apps
    version: v1
    resource: deployments
```

A rule then references this cached entry through Kyverno's variable context instead of performing its own live lookup on every admission request — the same data, fetched once, shared cluster-wide.

## Reference

- `kubectl explain policyexception.spec` — live schema for `PolicyException` on your installed version.
- `kubectl explain clustercleanuppolicy.spec` — live schema for `ClusterCleanupPolicy`.
- Kyverno's policy-types documentation for the full, version-specific list of policy-authoring CRDs.
