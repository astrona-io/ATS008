# Question

Solve this question on: `terminal`

1.  Install Kyverno via the `kyverno/kyverno` Helm chart as release `kyverno`, into a dedicated namespace `kyverno` (create it as part of the install).
2.  Set `admissionController.replicas` to `2`.
3.  Set the admission controller container's resource **requests** to `cpu: 100m` and `memory: 128Mi`.
4.  Wait for the admission controller Deployment to become ready, then confirm the release with `helm list -n kyverno`.
