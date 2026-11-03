#!/usr/bin/env bash
set -eu

kubectl create namespace salvage-yard --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace outpost --dry-run=client -o yaml | kubectl apply -f -

echo "salvage-yard and outpost ready."
