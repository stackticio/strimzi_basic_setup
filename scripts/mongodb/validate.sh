#!/bin/bash

NOCOLOR='\033[0m'
RED='\033[0;31m'
GREEN='\033[0;32m'

# Namespace where MongoDB is installed
NAMESPACE="mongodb"

# Dynamically get the first running MongoDB pod name
POD_NAME=$(kubectl get pods -n $NAMESPACE -l 'app.kubernetes.io/name=mongodb' --field-selector=status.phase=Running -o jsonpath="{.items[0].metadata.name}")

# Check if a pod name was found
if [ -z "$POD_NAME" ]; then
  echo -e "${RED}No running MongoDB pods found in namespace $NAMESPACE.${NOCOLOR}"
  exit 1
fi

# Service name to check
SVC_NAME="mongodbdev"
# Hostname
MONGODB_HOST="${SVC_NAME}.${NAMESPACE}.svc.cluster.local"

# Fetch MongoDB credentials from Kubernetes secret
MONGODB_ROOT_PASSWORD=$(kubectl get secret mongodb-auth-secret -n $NAMESPACE -o jsonpath="{.data.mongodb-root-password}" | base64 --decode)
MONGODB_ROOT_USERNAME=$(kubectl get secret mongodb-auth-secret -n $NAMESPACE -o jsonpath="{.data.mongodb-root-username}" | base64 --decode)

echo "-----------------------------------------------"
echo "-- Start testing mongodbdev"
echo "-----------------------------------------------"

# Function to check MongoDB user login
check_mongodb_user_login() {
  local username=$1
  local password=$2
  local database=$3

  local login_output
  if login_output=$(kubectl exec -it $POD_NAME -n $NAMESPACE -- mongosh --username "$username" --password "$password" --authenticationDatabase "$database" --eval "db.stats()" 2>&1); then
    echo -e "${GREEN}Login successful for user $username on database $database.${NOCOLOR}"
  else
    echo -e "${RED}Login failed for user $username on database $database. Error: $login_output${NOCOLOR}"
    exit 1
  fi
}

# Check root user
check_mongodb_user_login "root" "$MONGODB_ROOT_PASSWORD" "admin"

echo -e "${GREEN}MongoDB standalone installation validation completed successfully.${NOCOLOR}"