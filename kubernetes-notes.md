# Kubernetes notes

This file contains notes on the Kubernetes cluster and its management.

## Create the application

```bash
kubectl apply -f populare-kubernetes.yaml
```

## Check connection to DB proxy service

```bash
kubectl exec populare-<suffix> -- curl -s populare-db-proxy/health
```

## Check connection to populare service

**Note: you can't connect to the populare service from a populare container.**
This may be a minikube issue. Instead, connect through the mock client.

```bash
kubectl exec mock-client-<suffix> -- curl -s populare
```
