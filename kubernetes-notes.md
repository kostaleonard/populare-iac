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

## Open populare web app in browser using minikube

```bash
minikube service populare
```

This is a shortcut that opens a browser window to the minikube node's IP
address and populare service's nodeport. You could also get minikube's IP
address with `minikube ip` and the nodeport with `kubectl get svc populare`,
then navigate to that IP/port in your browser.
