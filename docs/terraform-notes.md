# Terraform notes

Terraform allows us to build infrastructure as code.

## Terraform deployment

1. Configure IAMs. See [iam-notes.md](iam-notes.md#policies-required-for-this-projects-plan)
for the minimum required IAM policies.
2. Apply the terraform plan.

   ```bash
   terraform apply
   ```

3. Update the kubeconfig so that `kubectl` links to the cluster.

   ```bash
   aws eks --region us-east-2 update-kubeconfig --name populare-cluster
   ```

4. Apply the kubernetes configuration.

   ```bash
   kubectl apply -f populare-kubernetes.yaml
   ```

5. Destroy provisioned infrastructure.

   ```bash
   terraform destroy
   ```
