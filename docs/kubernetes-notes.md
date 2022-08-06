# Kubernetes notes

This file contains notes on the Kubernetes cluster and its management.

## Minikube and offline deployment

You can run an offline version of the app in minikube. The only extra step is
to configure the database URI secret. You can set up an RDS instance and
provide its URI as the secret, or you can have an in-memory database in the
container running the database proxy. If you choose the latter, note that you
must keep the replica count of the database proxy pods (populare-db-proxy) set
to 1.

```bash
# From kubernetes-standalone/
kubectl create secret generic db-certs --from-literal=db-uri=sqlite:////tmp/populare_rds.db
kubectl apply -f populare-kubernetes.yaml
```

## Create the application

```bash
kubectl apply -f populare-kubernetes.yaml
```

## Check connection to DB proxy service

```bash
kubectl exec populare-<suffix> -- curl -s populare-db-proxy/health
```

## Check connection to service within cluster

**Note: you can't connect to a service from a container backing that service.**
This may be a minikube issue, but appears to be well-known. Instead, connect
through the mock client.

```bash
kubectl exec mock-client-<suffix> -- curl -s populare
```

## Open populare web app in browser using minikube

```bash
minikube service reverse-proxy
```

This is a shortcut that opens a browser window to the minikube node's IP
address and the reverse-proxy service's nodeport. You could also get minikube's
IP address with `minikube ip` and the nodeport with
`kubectl get svc reverse-proxy`, then navigate to that IP/port in your browser.
