#!/bin/bash

NOCOLOR='\033[0m'
RED='\033[0;31m'
GREEN='\033[0;32m'

# Namespace where PostgreSQL is installed
NAMESPACE="postgresql"
# Pod name to check
POD_NAME_PREFIX="postgresql"
# Service name to check
SVC_NAME="postgresql"
# Hostname
POSTGRES_HOST="${SVC_NAME}.${NAMESPACE}.svc.cluster.local"
# Default database name
POSTGRES_DB="postgres"


 # Fetch PostgreSQL admin password from Kubernetes secret
 POSTGRES_PASSWORD=$(kubectl get secret postgresql-admin-password -n $NAMESPACE -o jsonpath="{.data.postgres-password}" | base64 --decode)

 echo "-----------------------------------------------"
 echo "-- Start testing postgresql"
 echo "-----------------------------------------------"

 # Delete existing postgresql-client pod if it exists
 echo "Checking if postgresql-client pod needs to be deleted..."
 if kubectl get pod postgresql-client -n $NAMESPACE &> /dev/null; then
     echo "Deleting existing postgresql-client pod..."
     kubectl delete pod postgresql-client -n $NAMESPACE
 fi

 # Check if the PostgreSQL pod is running
 echo "Checking if the PostgreSQL pod is running..."
 POD_STATUS=$(kubectl get pods -l app.kubernetes.io/name=postgresql -n $NAMESPACE -o=jsonpath='{.items[0].status.phase}')
 if [ "$POD_STATUS" == "Running" ]; then
   echo -e "${GREEN}PostgreSQL pod is running.${NOCOLOR}"
 else
   echo -e "${RED}PostgreSQL pod is not running. Current status: $POD_STATUS${NOCOLOR}"
   exit 1
 fi

 # Check if the PostgreSQL service is accessible
 echo "Checking if the PostgreSQL service is accessible..."
 SVC_CLUSTER_IP=$(kubectl get svc $SVC_NAME -n $NAMESPACE -o=jsonpath='{.spec.clusterIP}')
 if [ "$SVC_CLUSTER_IP" != "<none>" ] && [ ! -z "$SVC_CLUSTER_IP" ]; then
   echo -e "${GREEN}PostgreSQL service is accessible at ClusterIP: $SVC_CLUSTER_IP${NOCOLOR}"
 else
   echo -e "${RED}PostgreSQL service is not accessible.${NOCOLOR}"
   exit 1
 fi

 # Function to check PostgreSQL admin login
 check_postgresql_admin_login() {
   echo "Attempting to log in as admin..."
   # Use --quiet to suppress the "pod deleted" message and avoid needing to press enter
   if kubectl run postgresql-client --namespace $NAMESPACE --quiet --rm --tty=false --stdin=true --restart='Never' \
     --image docker.io/bitnami/postgresql:latest --env="PGPASSWORD=$POSTGRES_PASSWORD" --command -- \
     psql -h $POSTGRES_HOST -U postgres -d $POSTGRES_DB -c '\l'; then
     echo -e "${GREEN}Successfully logged in as admin.${NOCOLOR}"
   else
     echo -e "${RED}Failed to log in as admin.${NOCOLOR}"
     exit 1
   fi
 }

 # Check admin login
 check_postgresql_admin_login

 echo -e "${GREEN}PostgreSQL validation completed successfully.${NOCOLOR}"
