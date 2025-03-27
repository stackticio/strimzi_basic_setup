# apisix documentation

## Usage

```bash
# Deploy
kubectl apply -k $STACKTIC_OUTPUT/k8s/deploy/overlays/dev/apisix

# Check deployment
kubectl get all -n ingress-apisix
```

## Access

Create a DNS A record for the ingress is the external controller IP

```sh
kubectl get services -n ingress-apisix
```

>💡 For local development, you can add an entry in your `/etc/hosts` `$EXTERNAL-IP $APP_NAME.apps.source-lab.io`

## Debug

```bash
# Run validation scripts
sh $STACKTIC_OUTPUT/apisix/scripts/validate.sh

# Check the Kong Ingress Controller logs
echo "Checking Kong Ingress Controller logs..."
kubectl logs -n ingress-apisix -l app.kubernetes.io/name=apisix
```

