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
