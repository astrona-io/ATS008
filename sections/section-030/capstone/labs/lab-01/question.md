# Question

Solve this question on: `terminal`

Kyverno is installed with Helm as release `kyverno` in namespace `kyverno`. Using a single Helm values file and one `helm upgrade`, configure two controllers at once:

1.  On the **admission controller**, set `extraArgs` so it runs with all three flags: `--webhookTimeout=15`, `--enablePolicyException=true` and `--exceptionNamespace=capstone-030`. Its `extraArgs` map sits under `container`.
2.  On the **cleanup controller**, set `extraArgs` so it runs with `--ttlReconciliationInterval=5m`. Its `extraArgs` map sits directly under the controller.
3.  Apply both changes with one `helm upgrade --reuse-values -n kyverno kyverno kyverno/kyverno -f <your values file>`, wait for both Deployments to roll out, then confirm every flag appears on the correct controller.
