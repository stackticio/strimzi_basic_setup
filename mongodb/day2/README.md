# MongoDB Day 2 Operations

This README outlines the Day 2 operational configurations for MongoDB in a Kubernetes environment, focusing on backup and restore functionalities.

## Overview

The configurations include a set of Kubernetes resources designed to manage backups and restores of MongoDB data. These operations are crucial for ensuring data durability and recoverability.

## Configurations

### Persistent Volume Claim (PVC) for Backup Storage

- **File**: `mongodb-backup-pvc.yaml`
- **Purpose**: Allocates storage for MongoDB backups.
- **Details**: 
  - `ReadWriteOnce` access mode.
  - Requests 10Gi storage (adjustable as needed).
  - Uses the `standard` storage class (modifiable to fit your environment).

### MongoDB Backup CronJob

- **File**: `mongodb-backup-cronjob.yaml`
- **Purpose**: Automates the backup process of MongoDB data.
- **Schedule**: Executes daily at 2:00 AM (modifiable as per requirements).
- **Details**:
  - Uses Bitnami MongoDB image.
  - Performs `mongodump` to create compressed backup files.
  - Stores backups in the PVC (`mongodb-backup-pvc`).

### Ad-hoc MongoDB Backup Job

- **File**: `mongodb-backup-job.yaml`
- **Purpose**: Provides a way to perform ad-hoc backups.
- **Details**:
  - Similar configuration to the CronJob.
  - Can be triggered manually as needed.

### Backup Checker Pod

- **File**: `backup-checker-pod.yaml`
- **Purpose**: Assists in verifying the backups.
- **Details**:
  - Uses a simple BusyBox image.
  - Mounts the backup PVC to check backup files.

### MongoDB Restore Job

- **File**: `mongodb-restore-job.yaml`
- **Purpose**: Facilitates the restoration of MongoDB data from backups.
- **Details**:
  - Restores data using `mongorestore`.
  - Targets the same backup PVC for source data.
 


## Usage

1. **Deploy the PVC**: Apply the `mongodb-backup-pvc.yaml` first as it's required for other components.
2. **Schedule Backups**: Deploy the `mongodb-backup-cronjob.yaml` to automate backups.
3. **Ad-hoc Backups**: Use `mongodb-backup-job.yaml` for manual backup operations.
4. **Backup Verification**: Deploy `backup-checker-pod.yaml` to access and verify backup files.
5. **Data Restoration**: Use `mongodb-restore-job.yaml` to restore data from backups.

## Customization

- Modify the storage size in the PVC configuration according to your backup needs.
- Adjust the backup schedule in the CronJob as per your operational requirements.
- Update MongoDB connection details and authentication parameters as needed (if you want to change the default secret)

#### if you want to run these YAMLs in declartive way , do the follow:
1) modify the deploy/base/kustomization.yaml
```yaml
resources:
  - namespace.yaml
  - mongodb.yaml
  - backup.yaml
```
2) copy the back.yaml to base deploy/base/

#### if you want to modify single YAML with all the configuraiton, you can unify multple commands as in the following format:
```yaml
        args:
        - |
          mongo --host mongodb.mongodb.svc.cluster.local -u $MONGODB_ROOT_USERNAME -p $MONGODB_ROOT_PASSWORD --authenticationDatabase admin \
          --eval "db = db.getSiblingDB('newDatabase1'); db.createUser({user: 'newUser1', pwd: 'newUserPassword1', roles: [{role: 'readWrite', db: 'newDatabase1'}]});" && \
          mongo --host mongodb.mongodb.svc.cluster.local -u $MONGODB_ROOT_USERNAME -p $MONGODB_ROOT_PASSWORD --authenticationDatabase admin \
          --eval "db = db.getSiblingDB('newDatabase2'); db.createUser({user: 'newUser2', pwd: 'newUserPassword2', roles: [{role: 'readWrite', db: 'newDatabase2'}]});"
        env:
```

These configurations ensure that your MongoDB deployment on Kubernetes is equipped with robust backup and restore capabilities, essential for maintaining data integrity and availability.

#### example
```
 kubectl apply -f stacktic-output/system/1/mongodb/day2/backup-job.yaml
 kubectl apply -f stacktic-output/system/1/mongodb/day2/restore-backup.yaml

 kubectl logs mongodb-backup-9wdrs    -n mongodb
2023-12-05T16:10:41.129+0000	writing admin.system.users to archive '/backup/mongodb-backup.gz'
2023-12-05T16:10:41.132+0000	done dumping admin.system.users (1 document)
2023-12-05T16:10:41.132+0000	writing admin.system.version to archive '/backup/mongodb-backup.gz'
2023-12-05T16:10:41.134+0000	done dumping admin.system.version (2 documents)
                                             
 kubectl get pods -n mongodb
NAME                       READY   STATUS      RESTARTS   AGE
mongodb-64588c888b-4nm8d   1/1     Running     0          24h
mongodb-backup-9wdrs       0/1     Completed   0          52s
mongodb-restore-bwzbp      0/1     Completed   0          10s

 ubectl logs mongodb-restore-bwzbp    -n mongodb     

2023-12-05T16:11:15.442+0000	preparing collections to restore from
2023-12-05T16:11:15.448+0000	restoring users from archive '/backup/mongodb-backup.gz'
2023-12-05T16:11:15.466+0000	0 document(s) restored successfully. 0 document(s) failed to restore.
 
 
 ### restore procuedure ###
 
 kubectl cp mongodb.json mongodb/mongodb-config-ingest-debug:/tmp/mongodb.json
 kubectl exec -it mongodb-config-ingest-debug   -n mongodb -- sh
# mongoimport --uri="mongodb://python:sauer12345@mongodb.mongodb.svc.cluster.local:27017/python_db" --collection=default_collector --type=json --file=/tmp/mongodb.json --authenticationDatabase=python_db  --jsonArray
2024-02-19T05:57:19.992+0000	connected to: mongodb://[**REDACTED**]@mongodb.mongodb.svc.cluster.local:27017/python_db
2024-02-19T05:57:19.995+0000	2 document(s) imported successfully. 0 document(s) failed to import. 
```

