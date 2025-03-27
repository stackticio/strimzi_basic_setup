#!/bin/sh

script_path=$(dirname "$0")

if [ -z "$1" ]; then
  output_path=$script_path/../../k8s/deploy/base/minio
else
  output_path=$script_path/$1
fi

helm template minio oci://registry-1.docker.io/bitnamicharts/minio \
  --namespace minio \
  --version 14.6.0 \
  --set networkPolicy.enabled=false \
  -f $script_path/helm-values.yaml \
  > $output_path/minio.yaml
