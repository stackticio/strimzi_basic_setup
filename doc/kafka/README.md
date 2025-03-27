# kafka Documentation

# kafka Documentation

**Table of Contents**

<!-- TOC -->
* [kafka Documentation](#-cookiecuttercomponentname--documentation)
    * [Component](#component)
        * [Overview](#overview)
        * [Versions](#versions)
        * [Stacktic Key Features](#stacktic-key-features)
        * [Template Supported Features](#template-supported-features)
        * [Prerequisites](#prerequisites)
        * [Dependencies](#dependencies)
    * [Structure Overview](#structure-overview)
    * [Installation and Configuration](#installation-and-configuration)
        * [Kubernetes](#kubernetes)
            * [Deploy](#deploy)
                * [Base Configuration](#base-configuration)
                * [Overlay Configuration](#overlay-configuration)
                * [Advanced](#advanced)
                * [SOPS Plugin](#sops-plugin)
    * [Usage](#usage)
        * [GUI Access](#gui-access)
        * [Image Updater](#image-updater)
    * [Connectors](#connectors)
        * [Minio Sink](#minio-sink)
        * [PSQL Sink](#psql-sink)
        * [Mongo Sink](#mongo-sink)
        * [Kafka Connect Image Version](#kafka-connect-image-version)
    * [Recommendations](#recommendations)
        * [Generality](#generality)
        * [Security](#security)
        * [Best Practices](#best-practices)
    * [Troubleshooting](#troubleshooting)
        * [Commands](#commands)
    * [Resources](#resources)
        * [Strimzi Documentation](#strimzi-documentation)
        * [Connectors Documentation](#connectors-documentation)
<!-- TOC -->



## Component

### Overview

Stacktic Kafka template is based on Strimzi operator (https://strimzi.io), that facilitates the deployment and operation of Apache Kafka related services.
By default, the template is set with a strict security approach.

#### Versions
- minio connector: https://camel.apache.org/camel-kafka-connector/4.8.x/reference/connectors/camel-minio-sink-kafka-sink-connector.html)
- psql connector:  https://camel.apache.org/camel-kafka-connector/4.8.x/reference/connectors/camel-postgresql-sink-kafka-sink-connector.html)
- mongo connector: https://www.mongodb.com/docs/kafka-connector/current/introduction/connect/
- kafka version:3.9.0
- helm chart: 0.45 
- source helm: https://github.com/strimzi/strimzi-kafka-operator/tree/main/helm-charts/helm3/strimzi-kafka-operator

### Stacktic Key Features

Fully Automated Deployment: Automated setup of observability, security, and connectors. For example:
- Security by Default: Mutual TLS (MTLS) enabled automatically for secure communication.
- Rich Connector Support: Automatic management of multiple source and sink connectors.
- Versioning and Management: Automated handling of versioning, lifecycle management, and internal topic creation. When a topic connects to a sink, Kafka automatically builds the - - connector image, provisions MTLS users and secrets, and integrates observability if Prometheus monitoring is configured.
- others: brdiges , mirrors , integration with Ingress , Keyclaok secret management and more
- Setup example:
  
  <img width="772" alt="image" src="https://github.com/user-attachments/assets/c86eba0f-0e68-4931-b8cf-24e16a300c78" />


#### Template Supported Features
**Deployments**:
- Kafka including topics user management (operator) 
- Kraft
- Kafka Exporter (topic monitoring)
- Kafka Connect (connectors for Source and Sink)
- Cruise Control (cluster workload monitoring and rebalancing)

**Pre-built integrations:**
- Producers and consumers:
    - JupyerHub
    - http support with KafkaBridge
    - Python backend (TBD)
    - Spring backend (TBD)
    - Spark (TBD)
- Kafka Connectors:
    - postgresql Sink
    - Mongodb Sink
    - Cassandra Source (TBD)
    - Minio Sink
    - Minio Source
    - PostgreSQL Sink (TBD)
    - PostgreSQL Source (TBD)

**Observability:**
- All supported components are integrated to Prometheus and Grafana, incliding predefined reports.
- Topic related metrics, like lag and offsets using Kafka Exporter
- Alerts (Day 2)

<img width="1593" alt="image" src="https://github.com/user-attachments/assets/27da6467-7227-4e99-b77e-7497040bf441" />


**Security atuomation aspects:**
- Intra Kafka communication (Brokers, Kraft and Connect) using mTLS.
- Producer and Consumers authentication using mTLS for intra-cluster components. Certificates and keys are automatically replicated to the relevant namespces using kubernetes-reflector service.
- Kong or APISIX Ingress integration for inter-cluster producers and consumers.
- Policies (NP / RBAC / OPA)
- Configmap as secret + SOPS  

**Additioanl Strimzi Key Features**:
The following features are supported by Strimzi, but not covered as part of the template, yet can be easily added by Stacktic user to the template:
- Kafka MirrorMaker - data replication between two Kafka clusters inter and intra data centers (TBD)
- OAuth 2.0 token-based authentication and authorization (Keycloak, OPA)
- OAuth 2.0 token-based authentication
- Distributed tracing (message tracing for Connect, MirrorMaker and Bridge)

## Structure Overview

### Deploy
```
kubectl apply -k k8s/deploy/base/kafka/
```

## Connectors

### Minio Sink
https://repo.maven.apache.org/maven2/org/apache/camel/kafkaconnector/camel-minio-sink-kafka-connector/4.8.5/camel-minio-sink-kafka-connector-4.8.5-package.tar.gz
### PSQL Sink
https://repo.maven.apache.org/maven2/org/apache/camel/kafkaconnector/camel-postgresql-sink-kafka-connector/4.8.5/camel-postgresql-sink-kafka-connector-4.8.5-package.tar.gz
### Mongo Sink
https://repo1.maven.org/maven2/org/mongodb/kafka/mongo-kafka-connect/1.15.0/mongo-kafka-connect-1.15.0-all.jar
### kafka connect image version
3.9.0

## Troubleshooting

###  test connectors:
```
############### message to topic-bucket  ##################

curl -X POST -k \                     
  -H "Content-Type: application/vnd.kafka.json.v2+json" \
  -H "Accept: application/vnd.kafka.v2+json" \
  --data '{
    "records": [
      {
        "key": "myKey",
        "value": {
          "username": "ddddjotestheddnd",
          "city": "SdddFOdedddd"
        }
      }
    ]
  }' \
https://bridge.apps.source-lab.io:443/topics/topic-bucket
{"offsets":[{"partition":0,"offset":0}]}% 

############### validate sink completed successfully  ##################

assafsauer@Assafs-MacBook-Pro test_4 %  mc --insecure ls myminio/kafkabucket/ |grep 21:56
[2025-03-25 21:56:16 CET]    53B STANDARD 9C0A638D727650D-0000000000000002
assafsauer@Assafs-MacBook-Pro test_4 %

############### message to topic-mongo  ##################

  curl -k -X POST "https://bridge.apps.source-lab.io:443/topics/topic" \
  -H "Content-Type: application/vnd.kafka.json.v2+json" \
  -d '{
        "records": [
        {
        "key": "myKey",
        "value": {
        "_id": "myDocument_1",      
        "hello": "all"   
        }
        }
        ]
  }' \
https://bridge.apps.source-lab.io:443/topics/topic-mongo
{"offsets":[{"partition":0,"offset":2}]}{"offsets":[{"partition":0,"offset":3}]}%                                         

############### validate sink completed successfully  ##################
kubectl port-forward -n mongodb mongodb-84c597d58c-ncr2t 27017:27017

 mongosh "mongodb://mongo:password_default1@127.0.0.1:27017/mongodb"

mongodb> db.collection_name.find().pretty()
[
  { _id: 'myDocumentId123', hello: 'world' },
  { _id: 'myDocumentId3232123', hello: 'worldds' },
  { _id: 'myDocumentId12d3', hello: 'world' },
  { _id: 'myDocument_1', hello: 'all' }
]
mongodb>

############### message to topic-psql  ##################

curl -X POST -k \
  -H "Content-Type: application/vnd.kafka.json.v2+json" \
  -H "Accept: application/vnd.kafka.v2+json" \
  --data '{
        "records": [
        {
        "key": "myKey",
        "value": {
        "username": "Iris",   
        "city": "SFO"
        }
        }
        ]
  }'  \
https://bridge.apps.source-lab.io:443/topics/topic-psql
{"offsets":[{"partition":0,"offset":3}]}%  

############### validate sink completed successfully  ##################
 kubectl run psql-cli-check -n postgresql -it \  
  --image=postgres:15 \
  --env PGPASSWORD=pass_default1 \
  -- bash


bash -c "psql -h postgresql.postgresql.svc.cluster.local -p 5432 -U user -d db1 -c 'SELECT * FROM accounts;'"
                       username                        |   city    
-------------------------------------------------------+-----------
 dany                                                  | NYC
 Daniel                                                | SFO
 Iris                                                  | SFO
(9 rows)

```



###  Useful debug Commands:
```
kubectl exec -it kafka-broker-kafka-0 -n strimzi -- bash

# 1) List all consumer groups
./kafka-consumer-groups.sh \
  --bootstrap-server kafka-kafka-bootstrap:9092 \
  --list

# 2) Describe all consumer groups (shows committed offsets, lag)
./kafka-consumer-groups.sh \
  --bootstrap-server kafka-kafka-bootstrap:9092 \
  --all-groups \
  --describe

# 3) Describe a specific group
./kafka-consumer-groups.sh \
  --bootstrap-server kafka-kafka-bootstrap:9092 \
  --group my-group-new-2030 \
  --describe

# 4) List all topics
./kafka-topics.sh \
  --bootstrap-server kafka-kafka-bootstrap:9092 \
  --list

# 5) Describe a topic’s partitions and replication
./kafka-topics.sh \
  --bootstrap-server kafka-kafka-bootstrap:9092 \
  --topic topic \
  --describe

# 6) Show the latest offsets for a topic
./kafka-run-class.sh kafka.tools.GetOffsetShell \
  --broker-list kafka-kafka-bootstrap:9092 \
  --topic topic \
  --time -1

# 7) Show the latest offsets for all topics
./kafka-run-class.sh kafka.tools.GetOffsetShell \
  --broker-list kafka-kafka-bootstrap:9092 \
  --all-topics \
  --time -1

# 8) Produce messages from the CLI (type lines, Ctrl+D to end)
./kafka-console-producer.sh \
  --broker-list kafka-kafka-bootstrap:9092 \
  --topic topic

# 9) Consume messages from the CLI (Ctrl+C to stop)
./kafka-console-consumer.sh \
  --bootstrap-server kafka-kafka-bootstrap:9092 \
  --topic topic \
  --from-beginning

```

## Resources

### Strimzi Documentation

Strimzi version specific documentation:

[Overview](https://strimzi.io/docs/operators/latest/overview)

[Deploying and Upgrading](https://strimzi.io/docs/operators/latest/deploying)

[API Reference](https://strimzi.io/docs/operators/latest/configuring)

[Strimzi Git](https://github.com/strimzi/strimzi-kafka-operator/tree/latest)

For License information, check Strimzi Git.


### Connectors Documentation

**Cassandra-Sink**
