# EKS notes

**Note: Direct use of EKS without terraform is deprecated because it requires
too much manual intervention. It was only ever a stop-gap until we added
terraform; please see [terraform-notes.md](terraform-notes.md).**

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

4. Create database connection string secret. You can provision an RDS instance
and use its database username, password, and URI for the connection string, or
you can use a local file as the database, as shown below. You will not be able
to scale the populare-db-proxy containers above 1 if you do the latter.

   ```bash
   kubectl create secret generic db-certs --from-literal=db-uri=sqlite:////tmp/populare_rds.db
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

## Allowing pods to make AWS API calls

Pods can make AWS API calls, e.g., using boto with some additional
configuration as described in the AWS docs [here](https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html).
Because that guide uses the AWS CLI rather than Terraform, it can be difficult
to reproduce, so we will provide additional documentation here.

For a pod to be able to make AWS API calls, it needs to run under a
ServiceAccount that has an annotation for the IAM role that the pod will
assume when it makes an API call. The IAM role will allow the ServiceAccount to
assume the role using the EKS cluster OIDC provider. Finally, we attach the
IAM policy allowing access to the resource (S3, SNS, etc.) to the IAM role so
that the pod will have that policy when it runs.

That's the process at a high level. Here's a specific example from
[kubernetes.tf](../kubernetes-tf/kubernetes.tf) to allow a pod to publish SNS
messages using boto.

```hcl
# The CronJob. Use the ServiceAccount with the ability to assume the IAM role.
# The ServiceAccount is the only additional configuration required here.
resource "kubernetes_manifest" "populare-sns-notifier-cronjob" {
  manifest = {
    "apiVersion" = "batch/v1"
    "kind" = "CronJob"
    "metadata" = {
      "name" = "populare-sns-notifier"
      "namespace" = "default"
    }
    "spec" = {
      "jobTemplate" = {
        "spec" = {
          "backoffLimit" = 1
          "template" = {
            "spec" = {
              "containers" = [
                {
                  "image" = "kostaleonard/populare_sns_notifier:0.0.2"
                  "name" = "populare-sns-notifier"
                  "volumeMounts" = [
                    {
                      "mountPath" = "/etc/populare-sns-notifier"
                      "name" = "populare-sns-notifier"
                    },
                  ]
                },
              ]
              "volumes" = [
                {
                  "configMap" = {
                    "name" = "populare-sns-notifier"
                  }
                  "name" = "populare-sns-notifier"
                },
              ]
              "restartPolicy" = "Never"
              "serviceAccountName" = "sns-publish"
            }
          }
        }
      }
      "schedule" = "*/5 * * * *"
    }
  }
}

# ServiceAccount with the annotation required to assume the specified role through OIDC.
# The annotation references the IAM role below.
resource "kubernetes_manifest" "sns-publish-serviceaccount" {
  manifest = {
    "apiVersion" = "v1"
    "kind" = "ServiceAccount"
    "metadata" = {
      "annotations" = {
        "eks.amazonaws.com/role-arn" = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/populare-sns-publish-role"
      }
      "name" = "sns-publish"
      "namespace" = "default"
    }
  }
}

# Create a role that pods in the EKS cluster can assume using the ServiceAccount and the OIDC provider.
# The cluster OIDC is taken from the EKS module outputs. It is a string like:
# oidc.eks.us-east-2.amazonaws.com/id/********
# The Terraform EKS module creates an OIDC by default; if the cluster does not have one, it will need to be created.
# The role allows the ServiceAccount defined above to assume.
resource "aws_iam_role" "sns_publish" {
  name = "populare-sns-publish-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${data.terraform_remote_state.populare_workspace_state.outputs.cluster_oidc_provider}"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "${data.terraform_remote_state.populare_workspace_state.outputs.cluster_oidc_provider}:aud": "sts.amazonaws.com",
          "${data.terraform_remote_state.populare_workspace_state.outputs.cluster_oidc_provider}:sub": "system:serviceaccount:default:sns-publish"
        }
      }
    }
  ]
}
EOF
}

# This is the policy containing the IAM roles we actually care about for our pod.
resource "aws_iam_policy" "sns_publish" {
  name        = "populare-sns-publish-policy"
  description = "Allow SNS:Publish on all resources"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "SNS:Publish",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

# Attach the policy to the role.
resource "aws_iam_role_policy_attachment" "sns_publish" {
  role       = aws_iam_role.sns_publish.name
  policy_arn = aws_iam_policy.sns_publish.arn
}
```
