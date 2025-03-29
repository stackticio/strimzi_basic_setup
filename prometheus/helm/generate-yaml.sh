#!/bin/sh

script_path=$(dirname "$0")

if [ -z "$1" ]; then
  output_path=$script_path/../../k8s/deploy/base/prometheus
else
  output_path=$script_path/$1
fi

 helm repo add bitnami https://charts.bitnami.com/bitnami
 helm repo update

helm template prometheus oci://registry-1.docker.io/bitnamicharts/kube-prometheus \
  --namespace prometheus \
  --version 10.2.3 \
  --include-crds \
  -f $script_path/helm-values.yaml \
  > $output_path/prometheus.yaml
