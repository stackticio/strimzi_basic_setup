# basic_kafka_setup

This is the output of the `basic_kafka_setup` system.
This sample repository provides an **initial Kafka Strimzi setup**, complete with basic connectors, monitoring, security, and more. We used **Helm 0.45** to generate the initial YAML templates, then switched to pure **Kustomize** for secrets, ConfigMaps, deployments, and day-two customizations and operations.
[kustomization.yaml](https://github.com/stackticio/strimzi_basic_setup/blob/main/k8s/deploy/base/kafka/kustomization.yaml) 
 Enjoy!

Quick Guide

1. **Modify Secrets**  
   Update any necessary secrets—such as your registry credentials—in the [registry.json](https://github.com/stackticio/strimzi_basic_setup/blob/main/k8s/deploy/base/kafka/secret/registry.json) file.

2. **View Documentation**  
   For more details and examples (e.g., Kafka-specific configuration), see the [Kafka docs](https://github.com/stackticio/strimzi_basic_setup/tree/main/doc/kafka).

3. **Deploy**  
   You can deploy with a single command, or integrate with your preferred GitOps workflow:
   ```bash
   kubectl apply -k k8s/deploy/overlays/dev/ --server-side=true --force-conflicts=true. 


## Design

<img width="870" alt="image" src="https://github.com/user-attachments/assets/f8835a61-4b3b-491d-9006-b711ef760ef8" />


## Folder structure

The folder structure is the following:
```
https://github.com/stackticio/strimzi_basic_setup
├── doc/
|   ├── stacktic
|   |   └── README.md
|   └── component-1
|   |   └── README.md
|   └── ...
└── k8s/
|   ├── build/
|   |   └── base/
|   |   |   └── stacktic
|   |   |   └── component-1
|   |   |   └── ...
|   |   └── overlays/
|   |   |   └── dev/
|   |   |   |   └── stacktic
|   |   |   |   └── component-1
|   |   |   |   └── ...
|   ├── deploy/
|   |   └── base/
|   |   |   └── stacktic
|   |   |   └── component-1
|   |   |   └── ...
|   |   └── overlays/
|   |   |   └── dev/
|   |   |   |   └── stacktic
|   |   |   |   └── component-1
|   |   |   |   └── ...
├── scripts/
|   └── stacktic/
|   |   └── validate-all.sh
|   |   └── ...
|   └── component-1/
|   |   └── validate.sh
|   └── ...
├── component-1
|   └── ...
└── ...
```

* `doc` - Documentation
* `k8s` - Kubernetes files
  * `k8s/build` - Kubernetes files to build projects
  * `k8s/deploy` - Kubernetes files to deploy components
    * `base` - Base configuration for Kustomize
    * `overlays` - Specific environment configuration for Kustomize
* `scripts` - Bash scripts for components. They'll contain the validation script to check deployments
* `component-xxx` - Sources of the various components

## Getting started

Refers to the [documentation](./doc/stacktic/README.md).



## Tips

* Do not use `"` for your variables in`*.env` secret files`
* Use Kustomize `namespace` functionality carefully, there may be component deployed in different namespace. You may want to use `NamespaceTransformer` to manage that. Exemple is the usage of Service Monitor which are deployed in the prometheus namespace, not the component one.

>⚠️ When you **delete** resources, **persistent volumes remain** to help ensure that no unintended data loss occurs. 
> If you create a new resource with the same name and persistent volumes, the **pre-existing data might cause issues** if the new resources have a different configuration than the previous ones.

## Resources

* [Kustomize introduction](https://github.com/beeNotice/kustomize-demo)
* [Recommended Labels](https://kubernetes.io/docs/concepts/overview/working-with-objects/common-labels/)
