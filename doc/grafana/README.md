# grafana documentation

## Deployment

```bash
# Deploy
kubectl apply -k $STACKTIC_OUTPUT/k8s/deploy/overlays/dev/grafana

# Check the status
kubectl get all --namespace grafana
```

## Usage

>💡 By default, the user is `admin` and the password is `default_password`.

```bash
# To access Grafana from outside the cluster with ClusterIP execute the following commands:
kubectl port-forward --namespace grafana svc/grafana 3000:3000
echo "Browse to http://127.0.0.1:3000"
```

## Customization

If you want to add a new dashboard
* Create your `json` file (the name and type of the default datasource are `prometheus`)
* Add the entry in your `kustomization.yaml`
* Add the entry in the `helm-values.yaml`
* Update this documentation
* You'll probably have to fix the json with the `DS_PROMETHEUS`
  * Remove the `__inputs` section
  * Replace `"datasource": "${DS_PROMETHEUS}"` with`"datasource": { "type": "prometheus", "uid": "prometheus" }`
* You'll probably want the dashboard to be non-editable, replace the editable attribute. 
* If there are variables in your dashboard, you probably want to exclude it from the cookiecutter engine by adding the entry in the `_copy_without_render` of the `cookiecutter.json` file
* Regenerate the `grafana.yaml` file by running the `helm/generate-yaml.sh` script

## Overlay configuration

```yaml
secretGenerator:
- name: grafana-admin-password
  namespace: grafana
  behavior: replace
  envs:
  - secret/grafana.env
```

## Annexes

### Dashboards

* [Cluster Monitoring for Kubernetes](https://grafana.com/grafana/dashboards/10000-kubernetes-cluster-monitoring-via-prometheus/)
* [JVM (Micrometer)](https://grafana.com/grafana/dashboards/4701-jvm-micrometer/)
* [PostgreSQL Database](https://grafana.com/grafana/dashboards/9628-postgresql-database/)
* [Kong (official)](https://grafana.com/grafana/dashboards/7424-kong-official/)
* [Keycloak](https://grafana.com/grafana/dashboards/10441-keycloak-metrics-dashboard/)
* [Node.js](https://grafana.com/grafana/dashboards/11159-nodejs-application-dashboard/)

### Resources

* [Grafana packaged by Bitnami](https://github.com/bitnami/charts/tree/main/bitnami/grafana)
