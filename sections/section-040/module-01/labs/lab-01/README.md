# Kyverno's RBAC Model Sandbox

Welcome to the Module 1 targeted practice sandbox. In this lab, you will diagnose a `generate` rule that fails for lack of RBAC on the background controller's ServiceAccount, then fix it with a correctly-labeled, aggregated `ClusterRole` — without ever touching one of Kyverno's own default roles.

## Launching the Lab
Run the following command in your terminal to boot the kind Kubernetes cluster:
```bash
astrona run --git git@github.com:astrona-io/ATS008.git -c sections/section-040/module-01/labs/lab-01
```
