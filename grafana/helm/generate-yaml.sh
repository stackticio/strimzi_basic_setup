#!/bin/sh

script_path=$(dirname "$0")

if [ -z "$1" ]; then
  output_path=$script_path/../../k8s/deploy/base/grafana
else
  output_path=$script_path/$1
fi
# helm repo add kedacore https://kedacore.github.io/charts
helm template grafana oci://registry-1.docker.io/bitnamicharts/grafana \
  --namespace grafana \
  --version 11.2.0 \
  --include-crds \
  -f $script_path/helm-values.yaml \
  > $output_path/grafana.yaml
