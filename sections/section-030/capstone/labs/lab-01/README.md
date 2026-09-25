# Controller Configuration Capstone Sandbox

Welcome to the Section 030 Capstone Challenge. In this lab, you will configure two different Kyverno controllers' flags in a single Helm upgrade, deliberately exercising the `extraArgs` nesting difference between the admission controller and the rest.

## Launching the Lab
Run the following command in your terminal to boot the kind Kubernetes cluster:
```bash
astrona run --git git@github.com:astrona-io/ATS008.git -c sections/section-030/capstone/labs/lab-01
```
