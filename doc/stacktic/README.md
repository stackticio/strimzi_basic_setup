# System documentation

## Prepare environment

### Environment

```bash
# Root directory of your System
export STACKTIC_OUTPUT=<FILL_ME>

# Configure AGE Key file to decrypt SOPS files
export SOPS_AGE_KEY_FILE=<FILL_ME>
```

### SOPS

```bash
# Download the binary
curl -LO https://github.com/getsops/sops/releases/download/v3.8.1/sops-v3.8.1.linux.amd64

# Move the binary in to your PATH
mv sops-v3.8.1.linux.amd64 /usr/local/bin/sops

# Make the binary executable
chmod +x /usr/local/bin/sops
```

> ℹ️ The SOPS releases are listed [here](https://github.com/getsops/sops/releases).

## Decrypt secrets

```bash
$STACKTIC_OUTPUT/scripts/stacktic/decrypt-secrets.sh
```

## Build all components

```bash
kubectl apply -k $STACKTIC_OUTPUT/k8s/build/overlays/dev/ --server-side=true --force-conflicts=true
```

## Deploy all components

```bash
kubectl apply -k $STACKTIC_OUTPUT/k8s/deploy/overlays/dev/ --server-side=true --force-conflicts=true
```

>💡You may encounter this kind of error `no matches for kind "XXX" in version "xxx.com/v1"`, reapply the deployment and the error shouldn't appear anymore.

## Check all components

```bash
$STACKTIC_OUTPUT/scripts/stacktic/validate-all.sh
```

## Components

You can find the documentation for each component here:

- [jupyterhub](../jupyterhub/README.md)
- [postgresql](../postgresql/README.md)
- [grafana](../grafana/README.md)
- [cert-manager](../cert-manager/README.md)
- [kafka](../kafka/README.md)
- [minio](../minio/README.md)
- [apisix](../apisix/README.md)
- [prometheus](../prometheus/README.md)
- [mongodb](../mongodb/README.md)

