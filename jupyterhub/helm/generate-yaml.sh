#!/bin/sh

script_path="$(dirname "$0")"

if [ -z "$1" ]; then
    output_path="$script_path/../../k8s/deploy/base/jupyterhub"
else
    output_path="$script_path/$1"
fi

helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update


helm template "jupyterhub" bitnami/jupyterhub  \
--namespace "jupyterhub" \
--version "7.2.12" \
-f $script_path/helm-values.yaml \
> "$output_path/jupyterhub-control.yaml" || exit 1


