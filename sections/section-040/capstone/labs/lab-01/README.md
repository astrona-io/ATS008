# Kyverno RBAC Capstone Challenge

Welcome to the Section 040 Capstone. In this lab, you will diagnose and fix a `generate` rule that fails to create `NetworkPolicy` resources for lack of RBAC on the background controller's ServiceAccount, reinforcing the aggregated-ClusterRole pattern across a different resource kind.

## Launching the Lab
Run the following command in your terminal to boot the kind Kubernetes cluster:
```bash
astrona run --git git@github.com:astrona-io/ATS008.git -c sections/section-040/capstone/labs/lab-01
```
