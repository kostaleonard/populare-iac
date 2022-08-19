# Terraform notes

Terraform allows us to build infrastructure as code.

## Terraform deployment

1. Configure IAMs. See [iam-notes.md](iam-notes.md#policies-required-for-this-projects-plan)
for the minimum required IAM policies.

2. Apply the EKS terraform plan.

   ```bash
   # From eks-tf/
   terraform init
   terraform apply
   ```

3. Update the kubeconfig so that `kubectl` links to the cluster. This step is
not strictly necessary to deploy the infrastructure, but it is handy to be able
to inspect and manage the cluster.

   ```bash
   aws eks --region us-east-2 update-kubeconfig --name populare-cluster
   ```

4. Apply the Kubernetes terraform plan. Running `terraform init` is important
because you are working in a different Terraform workspace. Note that load
balancers and other AWS resources created by the Kubernetes deployment may
not appear in the plan, but will be properly cleaned up on
`terraform destroy`.

   ```bash
   # From kubernetes-tf/
   terraform init
   terraform apply
   ```

5. Browse to the app. You can find the URL using the following. It may take a
minute or so for the service's hostname (backed by the load balancer) to
be ready.

   ```bash
   kubectl get svc reverse-proxy
   ```

6. Destroy provisioned infrastructure. As discussed in [this terraform PR](https://github.com/hashicorp/terraform/pull/29291),
all required variables must be defined even for destroy actions; they are not used.
First destroy the infrastructure provisioned by the Kubernetes plan, then the
infrastructure provisioned by the EKS plan. There should be no resources
remaining on AWS.

   ```bash
   # From kubernetes-tf/
   terraform destroy
   # From eks-tf/
   terraform init
   terraform destroy
   ```

## Converting Kubernetes manifests to Terraform resources

As noted in [this Terraform blog post](https://www.hashicorp.com/blog/deploy-any-resource-with-the-new-kubernetes-provider-for-hashicorp-terraform),
you can convert existing Kubernetes manifests into Terraform resources using
the following command. Note that the manifest can only contain one Kubernetes
resource.

```bash
echo 'yamldecode(file("my-manifest-file.yaml"))' | terraform console
```

Then add the manifest to the Terraform plan under a `kubernetes_manifest`
resource.
