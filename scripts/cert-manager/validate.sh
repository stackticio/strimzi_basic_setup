#!/bin/bash

# Color definitions for output
NOCOLOR='\033[0m'
RED='\033[0;31m'
GREEN='\033[0;32m'

# Namespace where Cert-Manager is installed
NAMESPACE="cert-manager"

# Labels for each Cert-Manager component
COMPONENT_LABELS=("app.kubernetes.io/name=cert-manager" "app.kubernetes.io/name=cainjector" "app.kubernetes.io/name=webhook")

echo "-----------------------------------------------"
echo "-- Start testing Cert-Manager"
echo "-----------------------------------------------"

# Check if the Cert-Manager pods are running
for LABEL in "${COMPONENT_LABELS[@]}"; do
  COMPONENT=$(echo $LABEL | cut -d '=' -f 2)
  echo "Checking if the $COMPONENT pod is running..."
  POD_STATUS=$(kubectl get pods -l $LABEL -n $NAMESPACE -o=jsonpath='{.items[0].status.phase}')
  if [ "$POD_STATUS" == "Running" ]; then
    echo -e "${GREEN}$COMPONENT pod is running.${NOCOLOR}"
  else
    echo -e "${RED}$COMPONENT pod is not running. Current status: $POD_STATUS${NOCOLOR}"
    exit 1
  fi
done

# Check for the existence of cluster issuers
echo "Checking for the existence of cluster issuers..."
if kubectl get clusterissuers; then
  echo -e "${GREEN}Found cluster issuers.${NOCOLOR}"
else
  echo -e "${RED}No cluster issuers found.${NOCOLOR}"
  exit 1
fi

# Check if the Certificate exists
CERT_NAMESPACE="cert-manager"
CERT_NAME="wildcard-certificate"
echo "Checking if Certificate $CERT_NAME exists in namespace $CERT_NAMESPACE..."
if kubectl get certificates.cert-manager.io $CERT_NAME -n $CERT_NAMESPACE; then
  echo -e "${GREEN}Certificate $CERT_NAME found in namespace $CERT_NAMESPACE.${NOCOLOR}"
else
  echo -e "${RED}Certificate $CERT_NAME not found in namespace $CERT_NAMESPACE.${NOCOLOR}"
  exit 1
fi

echo -e "${GREEN}Cert-Manager validation completed successfully.${NOCOLOR}"
