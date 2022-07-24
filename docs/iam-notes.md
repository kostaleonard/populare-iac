# IAM notes

Identity and Access Management (IAM) is Amazon's managed access control system.
IAM policies control which principals (users, accounts, etc.) can perform what
actions on what resources under what conditions. The goal of using IAMs is to
provide principals the least access required to perform their tasks.

## About policies

Policies can either be managed by AWS or user-defined. As far as I can tell,
managed policies are like presets that Amazon maintains for well-defined use
cases; user-defined policies are custom access control settings for niche or
growing use cases. Sometimes you can easily attach a single managed policy to a
user or group (for example, when granting access to [EC2](#ec2)), but sometimes
you need to attach multiple managed policies or even add user-defined policies
(for example, when granting access to [EKS](#eks)).

## Policies required for specific resources

### EC2

* AmazonEC2FullAccess (AWS Managed Policy)

### EKS

See the [eksctl documentation](https://eksctl.io/usage/minimum-iam-policies/)
for an explanation of the minimum required IAM policies and a definition of the
custom policies listed below.

* AmazonEC2FullAccess (AWS Managed Policy)
* AWSCloudFormationFullAccess (AWS Managed Policy)
* EksAllAccess (custom policy)
* IamLimitedAccess (custom policy)

### RDS

TODO

## IAM and Terraform

### Determining the minimum IAM permissions required for a plan

We would like a way to easily, programmatically identify all IAM policies that
Terraform needs to execute a particular plan. According to [this Terraform
issue](https://github.com/hashicorp/terraform/issues/2834), that is not
currently possible. The alternatives suggested include:

* Grant an IAM user full access to all resources, then use Terraform debug logs
to track AWS API calls and pare down permissions to only those that appear in
the logs.
* Apply the plan with the IAM user's current permissions. If the plan fails,
add the permissions that were missing. Repeat until the plan succeeds. There is
no way to know after any failed run how many more attempts will be required.

Neither alternative is particularly attractive. In the case of this project, we
used the latter approach with only 3 iterations.

### Policies required for this project's plan

* AmazonEC2FullAccess (AWS Managed Policy)
* AWSCloudFormationFullAccess (AWS Managed Policy)
* CloudWatchFullAccess (AWS Managed Policy)
* EksAllAccess (custom policy, linked in the [eksctl documentation](https://eksctl.io/usage/minimum-iam-policies/))
* IamLimitedAccess (custom policy, linked in the [eksctl documentation](https://eksctl.io/usage/minimum-iam-policies/))
* IamLimitedAccessTerraform (custom policy, defined [below](#iamlimitedaccessterraform))

#### IamLimitedAccessTerraform

Note that you will need to replace your AWS account ID with the 12-digit number
used in the "Resource" section. AWS account IDs are not sensitive information
[according to Amazon]((https://docs.aws.amazon.com/general/latest/gr/acct-identifiers.html)).

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "iam:CreateInstanceProfile",
                "iam:DeleteInstanceProfile",
                "iam:GetInstanceProfile",
                "iam:RemoveRoleFromInstanceProfile",
                "iam:GetRole",
                "iam:CreateRole",
                "iam:DeleteRole",
                "iam:AttachRolePolicy",
                "iam:PutRolePolicy",
                "iam:ListInstanceProfiles",
                "iam:AddRoleToInstanceProfile",
                "iam:ListInstanceProfilesForRole",
                "iam:PassRole",
                "iam:DetachRolePolicy",
                "iam:DeleteRolePolicy",
                "iam:GetRolePolicy",
                "iam:GetOpenIDConnectProvider",
                "iam:CreateOpenIDConnectProvider",
                "iam:DeleteOpenIDConnectProvider",
                "iam:TagOpenIDConnectProvider",
                "iam:ListAttachedRolePolicies",
                "iam:TagRole",
                "iam:GetPolicy",
                "iam:CreatePolicy",
                "iam:DeletePolicy",
                "iam:ListPolicyVersions"
            ],
            "Resource": [
                "arn:aws:iam::890362829064:role/populare-node-group-eks-node-group-*"
            ]
        }
    ]
}
```
