## Usage

```bash
# Deploy
kubectl apply -k $STACKTIC_OUTPUT/k8s/deploy/overlays/dev/minio

# Check deployment
kubectl get all -n minio
```

##  GUI

Default pass & users: 

user: change_access_key
pass: change_secret_key

```bash
kubectl port-forward --namespace minio svc/minio 9001:9001
echo "Browse to http://127.0.0.1:9001"
```

## Customization

```yaml
secretGenerator:
- name: minio-credentials
  namespace: minio
  behavior: replace
  envs:
    - secret/minio.env
  options:
    disableNameSuffixHash: true
```

## Debug

```sh
kubectl run --namespace minio --rm --tty -i --restart='Never' \
  --image minio/mc --command -- /bin/sh -c \
  "mc alias set myminio http://minio-service.mynamespace.svc.cluster.local:9000 myaccesskey mysecretkey && mc ls myminio"

# Check Ingester connectivity
kubectl get logs loki-grafana-loki-ingester-0 -n loki

```

### Test
```
 mc alias set myminio https://api.minio.apps.source-lab.io change_access_key change_secret_key --insecure

Added `myminio` successfully.

mc cp stack-metadata.yaml myminio/data/

...ack-metadata.yaml: 23.28 KiB / 23.28 KiB  ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓  15.84 KiB/s
mc --insecure  ls myminio/
```

kubectl port-forward svc/minio -n minio 9000:9000 (API)
kubectl port-forward svc/minio -n minio 9001:9001 (UI)

 mc alias set myminio http://localhost:9000 min8chars1 min8chars1 --insecure

Added `myminio` successfully.


### Resources

https://github.com/bitnami/charts/tree/main/bitnami/rabbitmq
https://grafana.com/docs/loki/latest/storage/#on-premise-deployment-minio-single-store
https://grafana.com/docs/loki/latest/configure/examples/#2-s3-cluster-exampleyaml
