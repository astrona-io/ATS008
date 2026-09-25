# Kyverno's CRD Surface Sandbox

Welcome to the Module 1 targeted practice sandbox. In this lab, you will enable `PolicyException` on a live admission controller, author one to exempt a single Pod from an existing `ClusterPolicy`, and confirm every other Pod is still enforced.

## Launching the Lab
Run the following command in your terminal to boot the kind Kubernetes cluster:
```bash
astrona run --git git@github.com:astrona-io/ATS008.git -c sections/section-020/module-01/labs/lab-01
```
