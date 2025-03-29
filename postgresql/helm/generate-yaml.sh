#!/bin/sh

script_path=$(dirname "$0")

if [ -z "$1" ]; then
  output_path=$script_path/../../k8s/deploy/base/postgresql
else
  output_path=$script_path/$1
fi

helm template postgresql oci://registry-1.docker.io/bitnamicharts/postgresql \
  --namespace postgresql \
  --version 15.4.0 \
  --include-crds \
  -f $script_path/helm-values.yaml \
  > $output_path/postgresql.yaml
