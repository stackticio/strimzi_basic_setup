#!/bin/sh

script_path=$(dirname "$0")

if [ -z "$1" ]; then
  output_path=$script_path/../../k8s/deploy/base/apisix
else
  output_path=$script_path/$1
fi

helm repo add apisix https://apache.github.io/apisix-helm-chart/
helm repo update

helm template apisix apisix/apisix \
  --namespace ingress-apisix \
  --version 2.10.0 \
  --set installCRDs=true \
  -f $script_path/helm-values-apix.yaml \
  > $output_path/apisix.yaml

helm template apisix-controller apisix/apisix-ingress-controller \
  --namespace ingress-apisix \
  --version 0.14.0 \
   --set installCRDs=true \
  -f $script_path/helm-values-controller.yaml \
  > $output_path/apisix-controller.yaml

helm template apisix-dashboard apisix/apisix-dashboard \
  --namespace ingress-apisix \
  --version 0.8.2 \
   --set installCRDs=true \
  -f $script_path/helm-values-dashboard.yaml \
  > $output_path/apisix-dashboard.yaml

