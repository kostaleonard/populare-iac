# Terraform notes

Terraform allows us to build infrastructure as code.

## Terraform deployment

1. Configure IAMs. See [iam-notes.md](iam-notes.md#policies-required-for-this-projects-plan)
for the minimum required IAM policies.
2. Apply the terraform plan. Provide the database username and password values
(they can also be supplied as environment variables if working in CI/CD or some
other automated workflow). These will be stored as part of the database
connection URI secret in kubernetes, and will be mounted into populare-db-proxy
pods; you need not know the values yourself.

   ```bash
   terraform apply -var="db_username=<your-value>" -var="db_password=<your-secret-value>"
   ```

3. Update the kubeconfig so that `kubectl` links to the cluster.

   ```bash
   aws eks --region us-east-2 update-kubeconfig --name populare-cluster
   ```

4. Apply the kubernetes configuration.

   ```bash
   kubectl apply -f populare-kubernetes.yaml
   ```

5. Browse to the app. You can find the URL using the following.

   ```bash
   kubectl get svc reverse-proxy
   ```

6. Destroy provisioned infrastructure. As discussed in [this terraform PR](https://github.com/hashicorp/terraform/pull/29291),
all variables must be defined even for destroy actions; they are not used.

   ```bash
   terraform destroy -var="db_username=doesnotmatter" -var="db_password=doesnotmatter"
   ```
