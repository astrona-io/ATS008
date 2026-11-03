# Question

Solve this question on: `terminal`

1.  Install Kyverno with the `kyverno/kyverno` Helm chart into namespace `kyverno` (create it), release name `kyverno`, using a values file that sets:
    - `admissionController.replicas` to `3` and `backgroundController.replicas` to `2`
    - the admission controller PodDisruptionBudget to `maxUnavailable: 1` (clear the default `minAvailable`)
    - one admission `topologySpreadConstraints` entry: `maxSkew: 1`, `topologyKey: kubernetes.io/hostname`, `whenUnsatisfiable: ScheduleAnyway`, and a `labelSelector` with `matchLabels` `app.kubernetes.io/component: admission-controller`
    - the admission controller `priorityClassName` to `system-cluster-critical`
2.  Wait for the admission and background Deployments to become ready.
3.  Run `kubectl get pdb -n kyverno` and confirm the admission budget allows one disruption.

Leave the background controller's budget at its default.
