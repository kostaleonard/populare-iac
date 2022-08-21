# Populare IAC

This repository defines the infrastructure for the Populare app. Running
`terraform apply` provisions compute, load balancers, databases, logging, and
other services in AWS, then deploys all Populare microservices into Kubernetes
(EKS). Once deployed, users can access the web app from the load balancer URL;
administrators can access internal services through the VPN. Running
`terraform destroy` cleans up all infrastructure. Below is a system diagram.

TODO system diagram

## Microservices

TODO list implemented microservices and link to them

## Documentation

Please see the [docs](docs) directory for notes on specific microservices,
AWS-managed Cloud services like EKS and IAM, Terraform, and more.
