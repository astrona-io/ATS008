# Question

Solve this question on: `terminal`

1.  Install Kyverno via the `kyverno/kyverno` Helm chart into namespace `kyverno` (create it), release name `kyverno`, using the documented HA replica counts:
    - `admissionController.replicas=3`
    - `backgroundController.replicas=2`
    - `reportsController.replicas=2`
    - `cleanupController.replicas=2`
2.  Wait for all four controller Deployments to become ready.
3.  Run `kubectl get lease -n kyverno` and identify the current leader (`holderIdentity`) for the background controller's lease.
4.  Confirm `kubectl get pods -n kyverno` shows 3 Running pods for the admission controller. Use `kubectl get pods -n kyverno --show-labels` to discover the correct label selector rather than assuming one.
