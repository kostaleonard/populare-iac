# EKS notes

Elastic Kubernetes Service (EKS) is Amazon's managed Kubernetes service. We use
terraform to create our AWS infrastructure, but for testing purposes we can
also create a cluster in the AWS console or from the command line using
`eksctl`.

## Command line quickstart

1. Install `eksctl`. Follow the instructions [here](https://docs.aws.amazon.com/eks/latest/userguide/eksctl.html).
2. Set IAM roles. The minimum required IAM roles can be found [here](https://eksctl.io/usage/minimum-iam-policies/).
3. Create cluster. The cluster name needs to be unique from all previous stacks
   created using `eksctl` because data from previous runs is stored for logging
   and debugging, so you may need to increment the number at the end of the
   cluster name. Note that t2.micro nodes can only hold 1-4 pods each, so you
   may need to increase the number of instances or type of node.

   ```bash
   eksctl create cluster --name populare-cluster-7 --region us-east-2 --node-type t2.micro --nodes 4
   ```

5. Manage cluster with `kubectl`.

   ```bash
   kubectl apply -f populare-kubernetes.yaml
   ```

6. Destroy cluster.

   ```bash
   eksctl delete cluster --name populare-cluster-7
   ```

## Using AWS console

Navigate to the EKS service in the AWS console, select create cluster, and
follow the prompts. You can use the AWS command line interface as described
[here](https://docs.aws.amazon.com/eks/latest/userguide/create-kubeconfig.html)
to populate `~/.kube/config` with the configuration information required to
make `kubectl` interface with the EKS cluster.
