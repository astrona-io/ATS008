# Question

Solve this question on: `terminal`

Kyverno runs on this cluster. It was installed with Helm as release `kyverno` in the namespace `kyverno`, and a `ClusterPolicy` named `require-owner-label` refuses Pods that have no `owner` label. Remove Kyverno completely, so that nothing of it is left on the cluster:

1.  Uninstall the Helm release `kyverno`.
2.  Remove every validating and mutating webhook configuration that has `kyverno` in its name, if any remain.
3.  Remove every custom resource definition whose name ends in `kyverno.io`, if any remain.
4.  Remove the `kyverno` namespace and wait until it is gone.
5.  Check that an ordinary Pod without an `owner` label can now be created in the `default` namespace. Delete your test Pod afterwards.

Do not remove anything that does not belong to Kyverno. You do not need to remove custom resource definitions that end in `wgpolicyk8s.io`.
