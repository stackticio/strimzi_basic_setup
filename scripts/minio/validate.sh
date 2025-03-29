#!/bin/bash

NOCOLOR='\033[0m'
RED='\033[0;31m'
GREEN='\033[0;32m'

# Namespace where MinIO is installed
NAMESPACE="minio"

# Service name to check
SVC_NAME=minio

echo "-----------------------------------------------"
echo "-- Start testing minio"
echo "-----------------------------------------------"

# Check if the MinIO pod is running
echo "Checking if the MinIO pod is running..."
POD_STATUS=$(kubectl get pod -l app.kubernetes.io/name=$SVC_NAME -n $NAMESPACE -o jsonpath="{.items[0].status.phase}")
if [[ $POD_STATUS == "Running" ]]; then
  echo -e "${GREEN}MinIO pod is running.${NOCOLOR}"
else
  echo -e "${RED}MinIO pod is not running. Current status: $POD_STATUS${NOCOLOR}"
  exit 1
fi

# Check if the MinIO service is accessible
echo "Checking if the MinIO service is accessible..."
SVC_CLUSTER_IP=$(kubectl get svc $SVC_NAME -n $NAMESPACE -o=jsonpath='{.spec.clusterIP}')
if [ "$SVC_CLUSTER_IP" != "<none>" ] && [ ! -z "$SVC_CLUSTER_IP" ]; then
  echo -e "${GREEN}MinIO service is accessible at ClusterIP: $SVC_CLUSTER_IP${NOCOLOR}"
else
  echo -e "${RED}MinIO service is not accessible.${NOCOLOR}"
  exit 1
fi

# Extract MinIO credentials from the Kubernetes secret
MINIO_ROOT_USER=$(kubectl get secret minio-credentials -n $NAMESPACE -o=jsonpath='{.data.root-user}' | base64 --decode)
MINIO_ROOT_PASSWORD=$(kubectl get secret minio-credentials -n $NAMESPACE -o=jsonpath='{.data.root-password}' | base64 --decode)

# Check MinIO user login using mc client
echo "Attempting to connect to MinIO server..."
if kubectl run --namespace $NAMESPACE minio-client --rm --tty -i --restart='Never' \
  --image minio/mc --command -- /bin/sh -c \
  "mc alias set myminio http://$SVC_NAME.$NAMESPACE.svc.cluster.local:9000 $MINIO_ROOT_USER $MINIO_ROOT_PASSWORD && mc ls myminio"; then
  echo -e "${GREEN}Successfully connected to MinIO server.${NOCOLOR}"
else
  echo -e "${RED}Failed to connect to MinIO server.${NOCOLOR}"
  exit 1
fi

echo -e "${GREEN}MinIO standalone installation validation completed successfully.${NOCOLOR}"
