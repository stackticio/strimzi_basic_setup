#!/bin/sh

script_path=$(dirname "$0")

if [ -z "$1" ]; then
  output_path=$script_path/../../k8s/deploy/base/mongodb
else
  output_path=$script_path/$1
fi

helm template mongodb oci://registry-1.docker.io/bitnamicharts/mongodb \
  --namespace mongodb \
  --version 15.6.0 \
  -f $script_path/helm-values.yaml \
  > $output_path/mongodb.yaml
