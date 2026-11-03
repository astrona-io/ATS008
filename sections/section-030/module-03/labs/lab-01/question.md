# Question

Solve this question on: `terminal`

Kyverno is installed with Helm as release `kyverno` in namespace `kyverno`, at default values. A namespace named `mission-ops` exists, and a ClusterPolicy named `audit-owner-label` is installed. Do the following. Make every setting change with `helm upgrade`.

1.  Make the Kyverno webhooks skip the namespace `mission-ops`. They must keep skipping `kube-system`.
2.  Make the Kyverno webhooks fail open: when the admission controller cannot answer, requests must go through. Check on the live webhook configuration that no resource webhook has `failurePolicy: Fail`.
3.  Replace the TLS certificate of the admission controller with a new one. Do not use `kubectl edit`, and do not delete the ConfigMap `lab-baseline` in the `default` namespace.

The admission controller must be running and ready at the end.
