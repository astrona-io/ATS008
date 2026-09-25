# Question

Solve this question on: `terminal`

Install Kyverno via a **values file** (not `--set` flags) that:

1.  Sets `admissionController.replicas` to `2`.
2.  Disables the cleanup controller (`cleanupController.enabled: false`).
3.  Sets `config.excludeGroups` to a list containing Kyverno's two built-in defaults (`system:serviceaccounts:kube-system` and `system:nodes`) **plus** `system:serviceaccounts:ci`. Remember: overriding this list without re-listing the defaults would silently drop them.

Apply your values file with `helm upgrade --install` as release `kyverno` in a dedicated `kyverno` namespace.
