#!/usr/bin/env bash
# The admission controller certificate must have been replaced: its serial
# number must differ from the one recorded when the lab started.

set -u

secret="kyverno-svc.kyverno.svc.kyverno-tls-pair"

baseline=$(kubectl get configmap lab-baseline -n default -o jsonpath='{.data.admissionCertSerial}' 2>/dev/null)
if [[ -z "$baseline" ]]; then
  echo "FAIL: the starting serial (ConfigMap lab-baseline) is missing; do not delete it"
  exit 1
fi

current=""
for _ in $(seq 1 30); do
  crt=$(kubectl get secret "$secret" -n kyverno -o jsonpath='{.data.tls\.crt}' 2>/dev/null)
  if [[ -n "$crt" ]]; then
    current=$(echo "$crt" | base64 -d 2>/dev/null | openssl x509 -noout -serial 2>/dev/null | cut -d= -f2)
    [[ -n "$current" ]] && break
  fi
  sleep 3
done
if [[ -z "$current" ]]; then
  echo "FAIL: the secret $secret is missing or holds no certificate"
  exit 1
fi
if [[ "$current" == "$baseline" ]]; then
  echo "FAIL: the certificate still has its starting serial; delete the secret so that Kyverno issues a new one"
  exit 1
fi

echo "PASS: the admission certificate was replaced."
exit 0
