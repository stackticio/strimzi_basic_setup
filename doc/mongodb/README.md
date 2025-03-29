# mongodb documentation



## Links
For our data components, we adhere to a standardized templating approach, which involves creating the database and credentials through a backend component link.  


<img width="575" alt="image" src="https://github.com/user-attachments/assets/d3d0e906-8a22-46ba-b6a2-19230ea0ada3">

## backup 
The backup procedure is available via Velero. As a result, we have automated the backup and restore scripts as follows:
```
 ls -ltrh  velero/day2/restore/
total 16
-rw-r--r--  1 assafsauer  staff   491B Sep  2 13:44 mongodb-restore.yaml
-rw-r--r--  1 assafsauer  staff   503B Sep  2 13:44 postgresql-restore.yaml
 
```
<img width="423" alt="image" src="https://github.com/user-attachments/assets/d5789d56-9622-4974-a8d1-956d855cfb16">

## Usage

```bash
# Deploy
kubectl apply -k $STACKTIC_OUTPUT/k8s/deploy/overlays/dev/mongodb

# Check deployment
kubectl get all -n mongodb
```

## Debug

```sh

kubectl run --namespace mongodb mongodb-client --rm --tty -i --restart='Never' --image docker.io/bitnami/mongodb:4.4.10-debian-10-r0 --command -- bash

# Connect as Admin
mongo admin --host "mongodb.mongodb.svc.cluster.local" -u root -p default_password

# Connect as User
mongo admin --host "mongodb.mongodb.svc.cluster.local" -u nodejs -p nodejs --authenticationDatabase nodejs_db
```

## Tips
```sh
# create pvc for mongodb backup
kubectl apply -k $STACKTIC_OUTPUT/k8s/deploy/day2-examples/backup-pvc.yaml

# for backup/restore mongodb:
kubectl apply -k $STACKTIC_OUTPUT/k8s/deploy/day2-examples/backup-job.yaml
kubectl apply -k $STACKTIC_OUTPUT/k8s/deploy/day2-examples/restore-job.yaml

# for schedualre backup/restore of mongodb , please modify the schedule (schedule: "0 2 * * *")
kubectl apply -k $STACKTIC_OUTPUT/k8s/deploy/day2-examples/backup-cronjob.yaml

# validate job and backup
 kubectl logs job/mongodb-backup-cronjob-28336990 -n mongodb
2023-11-17T11:10:00.879+0000	writing admin.system.users to archive '/backup/mongodb-backup-20231117111000.gz'
2023-11-17T11:10:00.882+0000	done dumping admin.system.users (1 document)
2023-11-17T11:10:00.882+0000	writing admin.system.version to archive '/backup/mongodb-backup-20231117111000.gz'
2023-11-17T11:10:00.884+0000	done dumping admin.system.version (2 documents)

kubectl apply -k $STACKTIC_OUTPUT/k8s/deploy/day2-examples/backup-validate.yaml

 kubectl exec -it backup-checker -n mongodb -- ls -ltrh backup
total 24K    
drwxrws---    2 root     1001       16.0K Nov 13 16:02 lost+found
-rw-rw-r--    1 root     1001         848 Nov 17 11:03 mongodb-backup.gz
-rw-r--r--    1 1001     1001         848 Nov 17 11:10 mongodb-backup-20231117111000.gz
 
date
Fri Nov 17 12:12:46 CET 2023

```

## Resources

 
## Migration

# Database Migration to Kubernetes

This table outlines the steps for migrating MongoDB databases to Kubernetes, both online and offline.

| Migration Type                        | Source                                                                                                                                                                                                                                                                                                                | Destination (K8s)                                                                                                                                                                                                                                     |
|---------------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| **Mongodb (online: logical replication)** | Reconfigure the replica set to add the Kubernetes instance as a secondary node. <br><br> ```javascript<br>rs.add("k8s_mongo_host:27017")<br>``` | Once the data is fully replicated, you can step down the original primary and promote the Kubernetes instance to primary. <br><br> ```javascript<br>rs.stepDown()<br>rs.reconfig({ _id: "replicaSetName", members: [ { _id: 0, host: "k8s_mongo_host:27017" }, ... ] })<br>``` |
| **Mongodb (offline: Dump and Restore)** | Ensure no new writes are occurring to maintain data consistency during migration. This might involve pausing applications or setting the database to read-only mode. <br><br> ```bash<br>mongodump --host source_host --port 27017 --out /path/to/backup<br>``` | Use `mongorestore` to import the data into the MongoDB instance running in Kubernetes <br><br> ```bash<br>mongorestore --host k8s_mongo_host --port 27017 /path/to/backup<br>``` |
                                                          |

  # Endpoints for online migration
For online migration, we recommend temporarily exposing your database endpoints. While we aim to avoid exposing data layers directly via Kong for security reasons, in this specific scenario, we advise creating a one-time Ingress to expose the necessary endpoints for data replication. After the replication process is complete, you should delete the Ingress resource to restore the secure state of your environment.

```
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: mongodb
  namespace: mongodb
  labels:
    app.kubernetes.io/name: "mongodb"
    app.kubernetes.io/instance: "mongodb"
    app.kubernetes.io/component: "server"
    app.kubernetes.io/part-of: "basic-kafka-setup"
    app.kubernetes.io/managed-by: "stacktic"
  annotations:
    cert-manager.io/cluster-issuer: "issuer"
spec:
  ingressClassName:"kong"
  rules:
    - host: mongodbc.apps.source-lab.io
      http:
        paths:
            - path: /
              pathType: Prefix
              backend:
                service:
                  name: mongodb
                  port:
                    name: http
  tls:
    - hosts:
        - mongodb.apps.source-lab.io
      secretName: wildcard-tls-secret
```
