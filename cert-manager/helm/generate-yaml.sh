#!/bin/sh

script_path=$(dirname "$0")

if [ -z "$1" ]; then
  output_path=$script_path/../../k8s/deploy/base/cert-manager
else
  output_path=$script_path/$1
fi

helm repo add jetstack https://charts.jetstack.io --force-update
helm repo update

helm template cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --version 1.16.2 \
  --debug \
  --set crds.enabled=true \
  --set crds.keep=true \
  -f $script_path/helm-values.yaml \
  > $output_path/cert-manager.yaml
