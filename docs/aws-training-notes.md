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
* Application Load Balancer targets must be in public subnets.
* You can create a cross-region RDS read replica to improve disaster recovers,
scale operations closer to users, and facilitate migration.
