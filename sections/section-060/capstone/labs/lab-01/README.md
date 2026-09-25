# Upgrading Kyverno Capstone Sandbox

Welcome to the Section 060 Capstone Challenge. In this lab, you will run the complete backup-upgrade-verify flow around a live Kyverno upgrade: back up existing policies, upgrade the release with new replica and flag settings in one command, and prove the pre-existing policy came through untouched.

## Launching the Lab
Run the following command in your terminal to boot the kind Kubernetes cluster:
```bash
astrona run --git git@github.com:astrona-io/ATS008.git -c sections/section-060/capstone/labs/lab-01
```
