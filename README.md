# basic_kafka_setup

This is the output of the `basic_kafka_setup` system.

## Design

![Uploading image.png…]()


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
