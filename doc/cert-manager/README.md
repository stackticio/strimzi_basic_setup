# cert-manager documentation

## Content

- [Introduction](#introduction)
- [Deployment](#deployment)
- [Configuration](#configuration)
- [Troubleshooting guide](#troubleshooting-guide)
- [Tips](#tips)
- [Useful Links](#useful-links)

## Introduction

Cert-manager is a powerful, Kubernetes-native solution designed to automate the management and issuance of TLS certificates. 
It simplifies the process of obtaining, renewing, and using cryptographic certificates by integrating with various certificate authorities (CAs), such as Let's Encrypt. 
Cert-manager ensures that certificates are valid and up to date, removing the manual processes involved in deploying them for secure communication within your Kubernetes cluster.

### Key Features

- **Automated Certificate Management**: Automates the issuance and renewal of TLS certificates, significantly reducing manual efforts and potential for human error.
- **Support for Multiple Issuers**: Compatible with a variety of CAs, including Let's Encrypt, HashiCorp Vault, and options for self-signing, offering versatility in certificate sourcing.
- **Kubernetes-Native Integration**: Designed specifically for Kubernetes, utilizing Custom Resource Definitions (CRDs) to manage certificates and issuers within Kubernetes manifests.
- **ACME Protocol Compatibility**: Implements the Automated Certificate Management Environment (ACME) protocol for easy integration with ACME-compliant CAs.
- **Configurable and Flexible**: Provides a range of options for certificate configuration, catering to diverse requirements and deployment scenarios.
- **Secure Secret Management**: Safeguards certificates and keys as Kubernetes secrets, ensuring secure storage and handling of sensitive data.
- **Multi-Cluster Support**: Capable of managing certificates across multiple Kubernetes clusters, suitable for complex, distributed environments.
- **Private CA Integration**: Supports the use of private CAs for organizations needing internal trust models, crucial for certain enterprise environments.

### Benefits

- **Enhanced Security**: Automated renewal and management of certificates reduce risks associated with expired or misconfigured certificates.
- **Operational Efficiency**: Lowers the operational burden associated with manual certificate processes, freeing up valuable DevOps resources.
- **Scalability**: As a native Kubernetes application, it effectively scales with your Kubernetes environment, adeptly handling certificates in large and dynamic systems.
- **Compliance Assurance**: Helps maintain consistent compliance with security policies by ensuring continuous validity and proper configuration of certificates.
- **User-Friendly**: Integrates easily within Kubernetes, providing a straightforward and manageable approach to certificate management.
- **Adaptability**: Offers the flexibility to cater to various operational environments, whether utilizing public CAs, private CAs, or a hybrid approach.

## Deployment

```bash
# Deploy
kubectl apply -k $STACKTIC_OUTPUT/k8s/deploy/overlays/dev/cert-manager

# Check deployment
kubectl get all -n cert-manager
```

## Configuration

## Troubleshooting guide

```sh
kubectl logs -lapp=cert-manager  -n cert-manager
```

## Tips

* Do not use Kustomize namespace because there is stuff deployed in the namespace `kube-system` and in your specified namespace.
* You may encounter the message `no matches for kind "ClusterIssuer" in version "cert-manager.io/v1` during the first deployment. This error will solve automatically, if you apply it again after a couple of seconds, the message won't appear again.

## Useful Links

* [Securing NGINX-ingress](https://cert-manager.io/docs/tutorials/acme/nginx-ingress/#step-5---deploy-cert-manager)

