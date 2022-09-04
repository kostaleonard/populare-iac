# AWS training notes

The AWS "Architecting on AWS" course walks students through the design and
implementation of Cloud-native applications.

## Lab 1: Explore and interact with the AWS Management Console and AWS CLI

* There are many ways to interact with AWS resources, but all interaction uses
the AWS API. You can manage AWS resources with the AWS Management Console or
the AWS CLI.

## Lab 2: Build your Amazon VPC infrastructure

* A **public subnet** in a VPC has a route to an Internet Gateway that allows
both outbound and inbound traffic. Public subnets are reachable from the
Internet.
* A **private subnet** in a VPC does not have a route to an Internet Gateway.
Internet traffic cannot reach private subnets, but private subnets can reach
the Internet by including a route to a NAT Gateway in a public subnet.
* The EC2 Session Manager allows you to connect to EC2 instances through the
AWS Console even if they do not have SSH exposed.
* EC2 instances have a link-local address, `http://169.254.169.254/latest/meta-data/`,
configured as a metadata server. Instance information is available at that
endpoint.

## Lab 3: Create a database layer in your VPC infrastructure

* Users should not be able to reach the database. Use an Application Load
Balancer to send Internet traffic to EC2 instances in the VPC that are
responsible for interfacing with the database.
* Application Load Balancers function like Kubernetes Services: they provide a
single endpoint for clients to access an app, and requests are load-balanced
across EC2 instances that support the group.
* EC2 instances and Auto Scaling groups can be used as targets for Application
Load Balancers.
* You can create a cross-region RDS read replica to improve disaster recovers,
scale operations closer to users, and facilitate migration. Read replicas can
be promoted to the primary database.

## Lab 4: Configure high availability in your Amazon VPC

* High availability is achieved by deploying resources in multiple availability
zones. This includes EC2 nodes backed by Auto Scaling Groups, reader replicas
for RDS instances, and multiple NAT Gateways for private subnets.
* Use Auto Scaling Groups with multiple availability zones to provide high
availability of apps running on those instances.
* Auto Scaling Groups require launch templates to tell AWS how to create new
instances.

## Lab 5: Build a serverless architecture

* Events must often be propagated to subscribers in a strictly ordered manner.
To achieve message ordering, deduplication, and encryption, we use SNS and SQS.
* In this lab, we set up an SNS topic for events that occur in an S3 bucket,
order those events with SQS, and then deliver to Lambda for processing.
* You need to modify the SNS topic policy statement to allow AWS users and
resources to publish messages.
* Lambda functions need to use Roles that allow access to AWS resources.
* Lambda functions can be triggered by arbitrary AWS events.
* In S3, you can add lifecycle rules to expire, delete, and/or move data after
a certain period of time.

## Lab 6: Configure an Amazon CloudFront distribution with an Amazon S3 origin

* CloudFront provides the ability to distribute content with low latency and
high data transfer speeds. It is a managed content delivery network that
provides users access to server content and AWS resources.
* A CloudFront origin defines the location of the definitive, original version
of the delivered content.
* CloudFront behaviors specify which origin should be used for which requests,
as well as other options like request handling and headers.
* Origin Access Identity (OAI) requires users to access content through
CloudFront URLs instead of directly through service (e.g., S3) URLs.
* S3 buckets can be replicated across regions to improve disaster recovery.

## Lab 7: Capstone--build an AWS multi-tier architecture

* CloudFormation is Amazon's infrastructure as code solution. Infrastructure is
deployed based on YAML definitions.
