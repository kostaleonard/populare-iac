# Terraform notes

Terraform allows us to build infrastructure as code.

## Terraform deployment

1. Configure IAMs. See [iam-notes.md](iam-notes.md#policies-required-for-this-projects-plan)
for the minimum required IAM policies.
2. Set the `POPULARE_DB_USERNAME` and `POPULARE_DB_PASSWORD` environment
variables.

   ```bash
   export POPULARE_DB_USERNAME="<your_db_username>"
   export POPULARE_DB_PASSWORD="<your_db_password_at_least_8_chars>"
   ```

3. Apply the EKS terraform plan. Provide the database username and password
values.

   ```bash
   # From eks-tf/
   terraform init
   terraform apply -var="db_username=$POPULARE_DB_USERNAME" -var="db_password=$POPULARE_DB_PASSWORD"
   ```

4. Update the kubeconfig so that `kubectl` links to the cluster. This step is
not strictly necessary to deploy the infrastructure, but it is handy to be able
to inspect and manage the cluster.

   ```bash
   aws eks --region us-east-2 update-kubeconfig --name populare-cluster
   ```

6. Retrieve the RDS hostname for use in the Kubernetes plan.

   ```bash
   export POPULARE_RDS_HOSTNAME=$(terraform output -raw rds_hostname)
   ```

7. Apply the Kubernetes terraform plan. Provide the database username,
database password, and RDS hostname values. Running `terraform init` is important
because you are working in a different Terraform workspace. Note that load
balancers and other AWS resources created by the Kubernetes deployment may
not appear in the plan, but will be properly cleaned up on
`terraform destroy`.

   ```bash
   # From kubernetes-tf/
   terraform init
   terraform apply -var="db_username=$POPULARE_DB_USERNAME" -var="db_password=$POPULARE_DB_PASSWORD" -var="rds_hostname=$POPULARE_RDS_HOSTNAME"
   ```

8. Browse to the app. You can find the URL using the following. It may take a
minute or so for the service's hostname (backed by the load balancer) to
be ready.

   ```bash
   kubectl get svc reverse-proxy
   ```

9. Destroy provisioned infrastructure. As discussed in [this terraform PR](https://github.com/hashicorp/terraform/pull/29291),
all variables must be defined even for destroy actions; they are not used.
First destroy the infrastructure provisioned by the Kubernetes plan, then the
infrastructure provisioned by the EKS plan. There should be no resources
remaining on AWS.

   ```bash
   # From kubernetes-tf/
   terraform destroy -var="db_username=doesnotmatter" -var="db_password=doesnotmatter" -var="rds_hostname=doesnotmatter"
   # From eks-tf/
   terraform init
   terraform destroy -var="db_username=doesnotmatter" -var="db_password=doesnotmatter"
   ```
