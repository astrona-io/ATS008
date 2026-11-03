# Question

Solve this question on: `terminal`

An upgrade of the `kyverno` Helm release (namespace `kyverno`) went wrong. Revision 2 points the admission controller at an image tag that does not exist. The ClusterPolicy `require-cost-center-label` is running on the cluster.

1.  Find the broken revision: run `helm history kyverno -n kyverno` and look at the status of every revision.
2.  Roll the release back to revision 1 with `helm rollback`.
3.  Confirm `helm history kyverno -n kyverno` now has at least 3 revisions, that the newest revision has the status `deployed` and a description that says it is a rollback, and that revision 2 is `superseded`.
4.  Confirm the `kyverno-admission-controller` Deployment no longer uses the missing image, that every controller Deployment in the `kyverno` namespace has all its replicas available, and that no Pod in the namespace has an image pull error.
5.  Confirm the ClusterPolicy `require-cost-center-label` still exists and still blocks an unlabeled Pod in the `finance` namespace.
