# Prometheus notes

Prometheus is an open source monitoring tool. We use it to measure telemetry
such as request volume and response statistics, CPU and memory utilization, and
server health.

## Kubernetes

Apply the standalone Kubernetes configuration to deploy the apps and services,
including Prometheus. We used minikube for testing. The Kubernetes deployment
for Prometheus includes a ConfigMap with the Prometheus configuration
(`prometheus.yml` is required for the container); a ClusterRole to discover
services using the Kubernetes API server, as well as a ServiceAccount and
ClusterRoleBinding to connect the ClusterRole to the Prometheus pods; a service
to expose Prometheus containers internal to the cluster (not to external users
via a load balancer or the reverse proxy); and the Prometheus deployment with
the pod definition.

Access the cluster-internal Prometheus service. In minikube, you can create a
tunnel using the following command.

```bash
minikube service prometheus
```

That will open a tunnel and browser window to the Prometheus UI. At the top of
the page, select "Status->Service Discovery" to view the services that
Prometheus has discovered. You should see prometheus (Prometheus is set up to
monitor its own metrics as a sanity check) and about a dozen services that
Prometheus has discovered from the Kubernetes API server. Those Kubernetes
services include Kubernetes components like CoreDNS as well as the Populare
services that we have deployed: the web app, the database proxy, the Wireguard
VPN, and the reverse proxy.

If you navigate to "Status->Targets", you can see that many of the services are
marked as down--this is because they have not implemented a `/metrics`
endpoint. At the time of writing this guide, we have implemented two services
with metrics: Prometheus and the database proxy. Both of those should be marked
as up.

Under "Graph", we can view dashboards of metrics of interest. We need to define
these using PromQL queries. For example, we can monitor the number of
successful Flask requests per second for the database proxy with the following.
You can see screenshots of the Prometheus UI discovering the database proxy
in #33.

```
rate(
  flask_http_request_duration_seconds_count{status="200"}[30s]
)
```

Other PromQL signals to monitor for Prometheus-Flask-Exporter applications are
described [in that project's GitHub repository](https://github.com/rycus86/prometheus_flask_exporter/tree/master/examples/sample-signals).
They include errors per second, request duration (latency), memory usage, and
CPU usage. Below are the queries for CPU and memory usage. We have replaced the
job name from "example" to "kubernetes-service-endpoints", which is the name of
the Prometheus job to discover the Kubernetes services.

CPU usage:

```
rate(
  process_cpu_seconds_total{job="kubernetes-service-endpoints"}[30s]
)
```

Memory usage:

```
process_resident_memory_bytes{job="kubernetes-service-endpoints"}
```

## Terraform

TODO don't want to expose Prometheus over reverse proxy, since it should not be
accessible to everyone. Need to make it accessible over Wireguard.
