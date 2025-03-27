#!/bin/bash

NOCOLOR='\033[0m'
RED='\033[0;31m'
GREEN='\033[0;32m'

NAMESPACE="ingress-apisix"

# Dynamically get the service name
SERVICE_NAME=$(kubectl get svc -n $NAMESPACE | grep 'kong ' | awk '{print $1}')

echo "-----------------------------------------------"
echo "-- Start testing $SERVICE_NAME"
echo "-----------------------------------------------"

# Check the status of the Kong service
SERVICE_STATUS=$(kubectl get svc -n $NAMESPACE $SERVICE_NAME -o jsonpath="{.status.loadBalancer.ingress[*].ip}")
if [ -n "$SERVICE_STATUS" ]; then
  echo -e "${GREEN}Service is available at IP: $SERVICE_STATUS${NOCOLOR}"
else
  echo -e "${RED}Service is not available${NOCOLOR}"
fi

# Check the status of the Pods
pod_status=$(kubectl get pods -l app.kubernetes.io/name=$SERVICE_NAME -n $NAMESPACE --field-selector=status.phase=Running --output=jsonpath='{.items[*].status.phase}')

if [ -n "$pod_status" ]; then
  echo -e "${GREEN}Pods are running${NOCOLOR}"
else
  echo -e "${RED}Pods are not running${NOCOLOR}"
fi
