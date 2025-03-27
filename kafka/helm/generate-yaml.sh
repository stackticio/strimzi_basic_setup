#!/bin/sh

script_path="$(dirname "$0")"

if [ -z "$1" ]; then
    output_path="$script_path/../../k8s/deploy/base/kafka"
else
    output_path="$script_path/$1"
fi

helm repo add strimzi https://strimzi.io/charts/
helm repo update

helm template "kafka" strimzi/strimzi-kafka-operator  \
--namespace "strimzi" \
--version "0.45.0" \
--include-crds \
-f $script_path/helm-values.yaml \
> "$output_path/strimzi-control.yaml" || exit 1


