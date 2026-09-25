#!/usr/bin/env bash
set -eu

# This generate rule fires on every new Namespace and tries to create a
# ResourceQuota named "default-quota" inside it. The background controller's
# ServiceAccount is deliberately NOT granted permission on `resourcequotas`
# by this script -- the rule will silently fail to generate until the
# learner adds a correctly-labeled, aggregated ClusterRole. That diagnosis
# and fix is the entire point of this lab, so it does not matter here
# whether Kyverno's own default roles happen to already cover this kind in
# some version -- the lab is written to be robust either way.

cat <<'EOF' | kubectl apply -f -
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: generate-default-quota
spec:
  rules:
    - name: generate-quota-per-namespace
      match:
        any:
        - resources:
            kinds:
              - Namespace
      exclude:
        any:
        - resources:
            namespaces:
              - kube-system
              - kube-node-lease
              - kube-public
              - kyverno
      generate:
        apiVersion: v1
        kind: ResourceQuota
        name: default-quota
        namespace: "{{request.object.metadata.name}}"
        synchronize: true
        data:
          spec:
            hard:
              pods: "10"
EOF

echo "generate-default-quota ClusterPolicy applied."
