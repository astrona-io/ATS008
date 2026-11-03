# Overview: Kyverno's CRD Surface (Playground)

This playground is a training solar system with no grading. It runs **Kyverno v1.13.2**, installed from the release `install.yaml` file (a parts list, so there is no Helm release).

## What is in the box

| Item | State |
| --- | --- |
| Namespace `kyverno` | The four controllers: admission, background, reports and cleanup |
| Namespace `checkout` | An empty planet for your test ships |
| `ClusterPolicy` `require-owner-label` | Rule `check-owner-label`, set to `Enforce`: every Pod needs a non-empty `owner` label |
| `PolicyException` support | Off. The admission controller has no `--enablePolicyException=true` yet |

## Helpers

Paste these into your shell. `show_kyverno_crds` lists every Kyverno form. `launch_test_pod` launches a nginx Pod on `checkout`. Add `--labels=owner=crew` after the name to give it a label.

```sh
show_kyverno_crds() {
  kubectl get crd | grep -E "kyverno.io|wgpolicyk8s.io"
}
launch_test_pod() {
  kubectl run "$1" -n checkout --image=nginx:alpine "${@:2}"
}
```

## Practice tasks

- List the CRDs and sort each one into "you write it" or "Kyverno writes it".
- Read the served versions of `policyexceptions.kyverno.io` and `clustercleanuppolicies.kyverno.io`, then read their fields with `kubectl explain`.
- Launch a Pod without an `owner` label and read the refusal message. Launch one with `--labels=owner=crew` and see it pass.
- Read the live `args` of `kyverno-admission-controller`, add the two exception flags, and wait for the rollout.
- Write a `PolicyException` for one named Pod, prove it works, and prove another Pod is still refused.
- Look at `kubectl get policyreport -n checkout` and `kubectl get ephemeralreport -A`.
