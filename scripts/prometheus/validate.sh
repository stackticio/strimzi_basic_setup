#!/bin/bash

NOCOLOR='\033[0m'
RED='\033[0;31m'
GREEN='\033[0;32m'

NAMESPACE="prometheus"
RELEASE_NAME="prometheus-kube-prometheus-prometheus"

echo "-----------------------------------------------"
echo "-- Start testing prometheus"
echo "-----------------------------------------------"

echo "Checking Prometheus CRDs..."
if ! kubectl get crd prometheuses.monitoring.coreos.com >/dev/null 2>&1; then
  echo -e "${RED}Prometheus CRDs are not installed. Exiting...${NOCOLOR}"
  exit 1
fi
echo -e "${GREEN}All Prometheus CRDs are installed.${NOCOLOR}"

echo "Checking Prometheus pods..."
if ! kubectl get pods -n $NAMESPACE -l "app.kubernetes.io/name=prometheus,app.kubernetes.io/instance=$RELEASE_NAME" >/dev/null 2>&1; then
  echo -e "${RED}Prometheus pods are not running. Exiting...${NOCOLOR}"
  exit 1
fi
echo -e "${GREEN}All Prometheus pods are running.${NOCOLOR}"

echo "Checking Prometheus service..."
if ! kubectl get svc -n $NAMESPACE -l "app.kubernetes.io/name=prometheus,app.kubernetes.io/instance=$RELEASE_NAME" >/dev/null 2>&1; then
  echo -e "${RED}Prometheus service is not available. Exiting...${NOCOLOR}"
  exit 1
fi
echo -e "${GREEN}Prometheus service is available.${NOCOLOR}"

echo "Checking Prometheus pod readiness..."
POD_NAME=$(kubectl get pods -n $NAMESPACE -l "app.kubernetes.io/name=prometheus,app.kubernetes.io/instance=$RELEASE_NAME" -o jsonpath="{.items[0].metadata.name}")
if ! kubectl wait --for=condition=ready pod -n $NAMESPACE $POD_NAME --timeout=60s >/dev/null 2>&1; then
  echo -e "${RED}Prometheus pod is not ready. Exiting...${NOCOLOR}"
  exit 1
fi
echo -e "${GREEN}Prometheus pod is ready.${NOCOLOR}"

# Start kubectl port-forward command in the background
kubectl port-forward pods/${POD_NAME} 9090:9090 -n ${NAMESPACE} &

# Save the PID of the kubectl port-forward command
PORT_FORWARD_PID=$!

# Give it some time to establish the connection
sleep 5

# Check Prometheus health
HEALTH_RESPONSE=$(curl -s http://localhost:9090/-/healthy)

echo "Health check response: ${HEALTH_RESPONSE}"

if echo "${HEALTH_RESPONSE}" | grep -q "Prometheus Server is Healthy"; then
    echo -e "${GREEN}Prometheus is healthy.${NOCOLOR}"
else
    echo -e "${RED}Prometheus is not healthy. Exiting...${NOCOLOR}"
    # Stop the kubectl port-forward command
    kill ${PORT_FORWARD_PID}
    exit 1
fi

# Stop the kubectl port-forward command
kill ${PORT_FORWARD_PID}
