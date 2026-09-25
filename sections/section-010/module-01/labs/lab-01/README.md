# Helm Install & Values Customization Sandbox

Welcome to the Module 1 targeted practice sandbox. In this lab, you will install Kyverno from scratch via Helm, sizing the admission controller's replicas and resource requests through `--set` flags, and confirm the release with `helm list`.

## Launching the Lab
Run the following command in your terminal to boot the kind Kubernetes cluster:
```bash
astrona run --git git@github.com:astrona-io/ATS008.git -c sections/section-010/module-01/labs/lab-01
```
