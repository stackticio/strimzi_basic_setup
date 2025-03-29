# postgresql documentation

### links
For our data components, we adhere to a standardized templating approach, which involves creating the database and credentials through a backend component link.  

<img width="522" alt="image" src="https://github.com/user-attachments/assets/1377fab6-00e5-446f-b548-787664e040f0">

## backup 
The backup procedure is available via Velero. As a result, we have automated the backup and restore scripts as follows:
```
 ls -ltrh  velero/day2/restore/
total 16
-rw-r--r--  1 assafsauer  staff   491B Sep  2 13:44 mongodb-restore.yaml
-rw-r--r--  1 assafsauer  staff   503B Sep  2 13:44 postgresql-restore.yaml
 
```
<img width="480" alt="image" src="https://github.com/user-attachments/assets/377c7ad3-6fc2-4f3a-8aab-5a11de098592">
### Usage

```bash
# Deploy
kubectl apply -k $STACKTIC_OUTPUT/k8s/deploy/overlays/dev/postgresql

# Check deployment
kubectl get all -n postgresql
```

### Debug

```bash
# Connect to Pod
kubectl exec -it postgresql-0 -n postgresql -- /bin/sh

# Connect as admin
psql -U postgres

# Connect as a custom users


# PostgreSQL can be accessed via port 5432 on the following DNS names from within your cluster:
postgresql.postgresql.svc.cluster.local

# Check connectivity - Fill the <password>
kubectl run pgsql-client --image docker.io/bitnami/postgresql --rm -it --restart=Never \
--env="PGPASSWORD=change_me" --command -- psql  \
--host postgresql.postgresql.svc.cluster.local \
-U postgres -p 5432
```

### Override

```bash
secretGenerator:
- name: postgresql-initdb
  namespace: postgresql
  behavior: replace
  files:
    - config/initdb.sql
- name: postgresql-admin-password
  namespace: postgresql
  behavior: replace
  envs:
    - secret/postgresql.env
```

## Migration

# Database Migration to Kubernetes

This document outlines the steps for migrating PostgreSQL databases to Kubernetes, both online and offline.

| Migration Type                                   | Source                                                                                                                                                                                                                                                                                                                                                                                                               | Destination (K8s)                                                                                                                                                                                                                                                 |
|--------------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| **Postgres replication (online: logical replication)** | `ALTER SYSTEM SET wal_level = logical;`: Configures the PostgreSQL server to generate WAL records with enough detail to support logical replication. <br><br> `SELECT pg_create_logical_replication_slot('replication_slot', 'pgoutput');`: Creates a logical replication slot named `replication_slot`, which tracks changes that need to be replicated. <br><br> `CREATE PUBLICATION my_publication FOR ALL TABLES;`: Sets up a publication named `my_publication` that includes all tables in the database, indicating that changes to these tables should be replicated to subscribers. | Create a Subscription: <br><br> ```sql<br>CREATE SUBSCRIPTION my_subscription CONNECTION 'host=source_host port=5432 dbname=your_db user=your_user password=your_password' PUBLICATION my_publication;<br>``` <br><br> **Purpose:** Connects the Kubernetes PostgreSQL to the source database, subscribing to the publication and starting to replicate changes. |
| **Postgres (offline: Dump and Restore)**         | ```bash<br>pg_dump -Fc -h source_host -U source_user -d source_db -f /path/to/backup.dump<br>```                                                                                                                                                                                                                                                                                                                        | ```bash<br>pg_restore -h k8s_postgres_host -U k8s_user -d k8s_db /path/to/backup.dump<br>```                                                                                                                                                                         |


# Endpoints for online migration
For online migration, we recommend temporarily exposing your database endpoints. While we aim to avoid exposing data layers directly via Kong for security reasons, in this specific scenario, we advise creating a one-time Ingress to expose the necessary endpoints for data replication. After the replication process is complete, you should delete the Ingress resource to restore the secure state of your environment.

```
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: postgresql
  namespace: postgresql
  labels:
    app.kubernetes.io/name: "postgresql"
    app.kubernetes.io/instance: "postgresql"
    app.kubernetes.io/component: "server"
    app.kubernetes.io/part-of: "basic-kafka-setup"
    app.kubernetes.io/managed-by: "stacktic"
  annotations:
    cert-manager.io/cluster-issuer: "issuer"
spec:
  ingressClassName:"kong"
  rules:
    - host: postgres.apps.source-lab.io
      http:
        paths:
            - path: /
              pathType: Prefix
              backend:
                service:
                  name: postgresql
                  port:
                    name: http
  tls:
    - hosts:
        - postgres.apps.source-lab.io
      secretName: wildcard-tls-secret
```
