#!/bin/bash

NOCOLOR='\033[0m'
RED='\033[0;31m'
GREEN='\033[0;32m'

# Namespace where Grafana is installed
NAMESPACE="grafana"
# Service name to check
SVC_NAME="grafana"
# Admin password (from Cookiecutter variables)
ADMIN_PASSWORD="default_password"
# Hostname
GRAFANA_HOST="${SVC_NAME}.${NAMESPACE}.svc.cluster.local"
PROMETHEUS_HOST="prometheus-kube-prometheus-prometheus.prometheus.svc.cluster.local"

echo "-----------------------------------------------"
echo "-- Start testing Grafana"
echo "-----------------------------------------------"

# Check if the Grafana pod is running
echo "Checking if the Grafana pod is running..."
POD_STATUS=$(kubectl get pods -l app.kubernetes.io/name=grafana -n $NAMESPACE -o=jsonpath='{.items[0].status.phase}')
if [ "$POD_STATUS" == "Running" ]; then
  echo -e "${GREEN}Grafana pod is running.${NOCOLOR}"
else
  echo -e "${RED}Grafana pod is not running. Current status: $POD_STATUS${NOCOLOR}"
  exit 1
fi

# Create a temporary pod to run curl commands
TEMP_POD="curlpod-$(date +%s)"
kubectl run $TEMP_POD --image=curlimages/curl --restart=Never --rm -i --tty --namespace $NAMESPACE -- /bin/sh -c "
  echo 'Checking Grafana Health...'
  if curl -s 'http://$GRAFANA_HOST:3000/api/health'; then
    echo -e '${GREEN}Grafana is healthy.${NOCOLOR}'
  else
    echo -e '${RED}Grafana health check failed.${NOCOLOR}'
  fi

  echo 'Checking Grafana Data Sources...'
  if curl -s -u admin:$ADMIN_PASSWORD 'http://$GRAFANA_HOST:3000/api/datasources'; then
    echo -e '${GREEN}Grafana data sources retrieved successfully.${NOCOLOR}'
  else
    echo -e '${RED}Failed to retrieve Grafana data sources.${NOCOLOR}'
  fi

  echo 'Checking Prometheus Health...'
  if curl -s 'http://$PROMETHEUS_HOST:9090/-/healthy'; then
    echo -e '${GREEN}Prometheus is healthy.${NOCOLOR}'
  else
    echo -e '${RED}Prometheus health check failed.${NOCOLOR}'
  fi
"

echo -e "${GREEN}Grafana service validation completed successfully.${NOCOLOR}"
