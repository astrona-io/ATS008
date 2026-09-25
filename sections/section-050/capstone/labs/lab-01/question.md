# Question

Solve this question on: `terminal`

1.  Install Kyverno via the `kyverno/kyverno` Helm chart into namespace `kyverno` (create it), release name `kyverno`, in a single `helm install` that sets:
    - The documented HA replica counts: `admissionController.replicas=3`, `backgroundController.replicas=2`, `reportsController.replicas=2`, `cleanupController.replicas=2`
    - The admission controller container's resource **requests** to `cpu: 200m` / `memory: 256Mi` (right-sizing for the higher replica count under load)
2.  Wait for all four controller Deployments to become ready.
3.  Confirm both the replica counts and the resource requests landed correctly on the admission controller Deployment.
