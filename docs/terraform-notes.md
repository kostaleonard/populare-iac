# Terraform notes

Terraform allows us to build infrastructure as code.

## Terraform deployment

1. Configure IAMs. See [iam-notes.md](iam-notes.md#policies-required-for-this-projects-plan)
for the minimum required IAM policies.
2. Apply the terraform plan. Provide the database username and password values
(they can also be supplied as environment variables if working in CI/CD or some
other automated workflow).

   ```bash
   terraform apply -var="db_username=<db-username>" -var="db_password=<db-password>"
   ```

3. Update the kubeconfig so that `kubectl` links to the cluster.

   ```bash
   aws eks --region us-east-2 update-kubeconfig --name populare-cluster
   ```

4. Create the database connection secret. Because you cannot have providers
that depend on each other, terraform [recommends](https://github.com/hashicorp/terraform-provider-kubernetes/blob/main/_examples/eks/README.md)
creating two separate plans for the EKS and Kubernetes providers. For now, we
will create the secret ourselves.

   ```bash
   kubectl create secret generic db-certs --from-literal=db-uri=mysql+pymysql://<db-username>:<db-password>@$(terraform output -raw rds_hostname)/populare_db
   ```

5. Apply the kubernetes configuration.

   ```bash
   kubectl apply -f populare-kubernetes.yaml
   ```

6. Browse to the app. You can find the URL using the following.

   ```bash
   kubectl get svc reverse-proxy
   ```

7. Destroy provisioned infrastructure. As discussed in [this terraform PR](https://github.com/hashicorp/terraform/pull/29291),
all variables must be defined even for destroy actions; they are not used.

   ```bash
   terraform destroy -var="db_username=doesnotmatter" -var="db_password=doesnotmatter"
   ```
