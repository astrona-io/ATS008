# Question

Solve this question on: `terminal`

Using a single Helm values file and one `helm upgrade`, configure two controllers at once:

1.  On the **admission controller**, set `extraArgs` (remember: this one nests under `.container.`) to include all three flags: `--webhookTimeout=15`, `--enablePolicyException=true`, and `--exceptionNamespace=capstone-030`.
2.  On the **cleanup controller**, set `extraArgs` (flat, no `.container.` nesting) to include `--ttlReconciliationInterval=5m`.
3.  Apply both changes with `helm upgrade --reuse-values -n kyverno kyverno kyverno/kyverno -f values.yaml`, wait for both Deployments to roll out, then confirm every flag landed on the correct controller.
