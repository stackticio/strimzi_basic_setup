# prometheus documentation

## Deployment

```bash
# Deploy - Do not forget the  --force-conflicts=true --server-side=true
# to fix - CustomResourceDefinition.apiextensions.k8s.io "prometheuses.monitoring.coreos.com" is invalid: metadata.annotations: Too long: must have at most 262144 bytes
kubectl apply -k $STACKTIC_OUTPUT/k8s/deploy/overlays/dev/prometheus --force-conflicts=true --server-side=true

# Check the status
kubectl get all --namespace prometheus
```

## Usage

```bash
# Prometheus can be accessed via port "9090" on the following DNS name from within your cluster:
prometheus-kube-prometheus-prometheus.prometheus.svc.cluster.local

# To access Prometheus from outside the cluster execute the following commands:
echo "Prometheus URL: http://127.0.0.1:9090/"
kubectl port-forward --namespace prometheus svc/prometheus-kube-prometheus-prometheus 9090:9090

# Alertmanager can be accessed via port "9093" on the following DNS name from within your cluster:
prometheus-kube-prometheus-alertmanager.prometheus.svc.cluster.local

# To access Alertmanager from outside the cluster execute the following commands:
echo "Alertmanager URL: http://127.0.0.1:9093/"
kubectl port-forward --namespace prometheus svc/prometheus-kube-prometheus-alertmanager 9093:9093
```

## Troubleshooting

```bash
# Check connectivity
kubectl run busybox --image=busybox --rm -it --restart=Never \
-- wget -qO- http://prometheus-kube-prometheus-prometheus.prometheus.svc.cluster.local:9090

# Prometheus logs
kubectl logs -n prometheus -l app.kubernetes.io/name=kube-prometheus,app.kubernetes.io/instance=prometheus,app.kubernetes.io/component=operator --tail -1

# Registered Metrics
k get servicemonitor -prometheus
```

### Service Monitor

> ℹ️ You can check the scrap status through the GUI, on Status > Target

```bash
# List ServiceMonitor
k get servicemonitor -n prometheus

# Replace my-service-monitor by your Service name
SERVICE_MONITOR_NAME="my-service-monitor"

# Check that your Service is registered - 
kubectl get secret prometheus-prometheus-kube-prometheus-prometheus -n prometheus -ojson | jq -r '.data["prometheus.yaml.gz"]' | base64 -d | gunzip | grep -C5 $SERVICE_MONITOR_NAME

# Check that your service selector is well defined
kubectl get services -A -l "$(kubectl get servicemonitors -n prometheus $SERVICE_MONITOR_NAME -o template='{{ $first := 1 }}{{ range $key, $value := .spec.selector.matchLabels }}{{ if eq $first 0 }},{{end}}{{ $key }}={{ $value }}{{ $first = 0 }}{{end}}')"

# Check your ports, you must use textual port number instead of port number
```
> ℹ️ You may refer to the [official documentation](https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/troubleshooting.md#troubleshooting-servicemonitor-changes) for more details.



## get metrics list 
```
# ---------------------------------------------------------------------------
# cert-manager (ports: 9402)
# ---------------------------------------------------------------------------

kubectl port-forward -n cert-manager svc/cert-manager 9402:9402
curl -s http://localhost:9402/metrics | grep -E '^(# HELP|# TYPE)' | sort -u

kubectl port-forward -n cert-manager svc/cert-manager-cainjector 9402:9402
curl -s http://localhost:9402/metrics | grep -E '^(# HELP|# TYPE)' | sort -u

kubectl port-forward -n cert-manager svc/cert-manager-webhook 9402:9402
curl -s http://localhost:9402/metrics | grep -E '^(# HELP|# TYPE)' | sort -u


# ---------------------------------------------------------------------------
# elasticsearch (service: elasticsearch-metrics, port: 9114)
# ---------------------------------------------------------------------------

kubectl port-forward -n elasticsearch svc/elasticsearch-metrics 9114:9114
curl -s http://localhost:9114/metrics | grep -E '^(# HELP|# TYPE)' | sort -u


# ---------------------------------------------------------------------------
# gmp-system (Alertmanager on 9093)
# ---------------------------------------------------------------------------

kubectl port-forward -n gmp-system svc/alertmanager 9093:9093
curl -s http://localhost:9093/metrics | grep -E '^(# HELP|# TYPE)' | sort -u


# ---------------------------------------------------------------------------
# grafana (port: 3000, may require GF_METRICS_ENABLED=true)
# ---------------------------------------------------------------------------

kubectl port-forward -n grafana svc/grafana 3000:3000
curl -s http://localhost:3000/metrics | grep -E '^(# HELP|# TYPE)' | sort -u


# ---------------------------------------------------------------------------
# ingress-apisix (apisix-admin on 9180, if metrics are enabled)
# ---------------------------------------------------------------------------

kubectl port-forward -n ingress-apisix svc/apisix-admin 9180:9180
curl -s http://localhost:9180/metrics | grep -E '^(# HELP|# TYPE)' | sort -u


# ---------------------------------------------------------------------------
# keycloak (service: keycloak-metrics, port: 9000)
# ---------------------------------------------------------------------------

kubectl port-forward -n keycloak svc/keycloak-metrics 9000:9000
curl -s http://localhost:9000/metrics | grep -E '^(# HELP|# TYPE)' | sort -u


# ---------------------------------------------------------------------------
# kube-system (metrics-server on 443 over HTTPS)
# ---------------------------------------------------------------------------

kubectl port-forward -n kube-system svc/metrics-server 443:443
curl -k -s https://localhost:443/metrics | grep -E '^(# HELP|# TYPE)' | sort -u


# ---------------------------------------------------------------------------
# loki (each component typically on port 3100)
# ---------------------------------------------------------------------------

kubectl port-forward -n loki svc/loki-grafana-loki-compactor 3100:3100
curl -s http://localhost:3100/metrics | grep -E '^(# HELP|# TYPE)' | sort -u

kubectl port-forward -n loki svc/loki-grafana-loki-distributor 3100:3100
curl -s http://localhost:3100/metrics | grep -E '^(# HELP|# TYPE)' | sort -u

kubectl port-forward -n loki svc/loki-grafana-loki-ingester 3100:3100
curl -s http://localhost:3100/metrics | grep -E '^(# HELP|# TYPE)' | sort -u

kubectl port-forward -n loki svc/loki-grafana-loki-querier 3100:3100
curl -s http://localhost:3100/metrics | grep -E '^(# HELP|# TYPE)' | sort -u

kubectl port-forward -n loki svc/loki-grafana-loki-query-frontend 3100:3100
curl -s http://localhost:3100/metrics | grep -E '^(# HELP|# TYPE)' | sort -u

kubectl port-forward -n loki svc/loki-grafana-loki-promtail 3100:3100
curl -s http://localhost:3100/metrics | grep -E '^(# HELP|# TYPE)' | sort -u


# ---------------------------------------------------------------------------
# prometheus
# ---------------------------------------------------------------------------

kubectl port-forward -n prometheus svc/prometheus-kube-prometheus-alertmanager 9093:9093
curl -s http://localhost:9093/metrics | grep -E '^(# HELP|# TYPE)' | sort -u

kubectl port-forward -n prometheus svc/prometheus-kube-prometheus-blackbox-exporter 19115:19115
curl -s http://localhost:19115/metrics | grep -E '^(# HELP|# TYPE)' | sort -u

kubectl port-forward -n prometheus svc/prometheus-kube-prometheus-operator 8080:8080
curl -s http://localhost:8080/metrics | grep -E '^(# HELP|# TYPE)' | sort -u

kubectl port-forward -n prometheus svc/prometheus-kube-prometheus-prometheus 9090:9090
curl -s http://localhost:9090/metrics | grep -E '^(# HELP|# TYPE)' | sort -u

kubectl port-forward -n prometheus svc/prometheus-kube-state-metrics 8080:8080
curl -s http://localhost:8080/metrics | grep -E '^(# HELP|# TYPE)' | sort -u

kubectl port-forward -n prometheus svc/prometheus-node-exporter 9100:9100
curl -s http://localhost:9100/metrics | grep -E '^(# HELP|# TYPE)' | sort -u

kubectl port-forward -n prometheus svc/pushgateway 9091:9091
curl -s http://localhost:9091/metrics | grep -E '^(# HELP|# TYPE)' | sort -u


# ---------------------------------------------------------------------------
# rabbitmq (port: 9419)
# ---------------------------------------------------------------------------

kubectl port-forward -n rabbitmq svc/rabbitmq 9419:9419
curl -s http://localhost:9419/metrics | grep -E '^(# HELP|# TYPE)' | sort -u
```
## Resources

* [Prometheus Operator packaged by Bitnami](https://github.com/bitnami/charts/tree/main/bitnami/kube-prometheus/)
* [How to monitor Kubernetes clusters with the Prometheus Operator](https://grafana.com/blog/2023/01/19/how-to-monitor-kubernetes-clusters-with-the-prometheus-operator/)
