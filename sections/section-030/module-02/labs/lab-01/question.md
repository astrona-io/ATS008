# Question

Solve this question on: `terminal`

Kyverno is installed with Helm as release `kyverno` in namespace `kyverno`, at default values. A namespace named `mission-ops` exists. Change the Kyverno ConfigMap, named `kyverno`, with `helm upgrade` only:

1.  Exclude the user `system:serviceaccount:mission-ops:flight-bot` from Kyverno's checks. The default excluded group `system:nodes` must stay.
2.  Make Kyverno generate success events.
3.  Make Kyverno skip the namespace `mission-ops` through its resource filters. Every default filter entry must stay in the list.

Then read the ConfigMap back and check that all three changes are there.
