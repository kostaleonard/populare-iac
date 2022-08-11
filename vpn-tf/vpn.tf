module "vpc" {
  # TODO use the VPC from EKS run
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.77.0"

  name                 = "populare-vpn-vpc"
  cidr                 = "10.0.0.0/16"
  azs                  = ["us-east-2a", "us-east-2b", "us-east-2c"]
  private_subnets      = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets       = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  enable_dns_hostnames = true
  enable_dns_support   = true
}

resource "aws_acm_certificate" "vpn_server" {
  domain_name = "example-vpn.example.com" # TODO change domain name
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_acm_certificate_validation" "vpn_server" {
  # Use of this resource rather than the aws_acm_certificate ensures that the
  # certificate was correctly created.
  certificate_arn = aws_acm_certificate.vpn_server.arn

  timeouts {
    create = "1m"
  }
}

resource "aws_acm_certificate" "vpn_client_root" {
  private_key = file("../../certs/VPN_CA.key") # TODO not sure if "file" will work in terraform cloud
  certificate_body = file("../../certs/VPN_CA.pem")
  certificate_chain = file("../../certs/CA_Chain.pem")
}

resource "aws_ec2_client_vpn_endpoint" "vpn" {
  description = "Client VPN example"
  client_cidr_block = "10.20.0.0/22"
  split_tunnel = true
  server_certificate_arn = aws_acm_certificate_validation.vpn_server.certificate_arn

  authentication_options {
    type = "certificate-authentication"
    root_certificate_chain_arn = aws_acm_certificate.vpn_client_root.arn
  }

  connection_log_options {
    enabled = false
  }
}

resource "aws_security_group" "vpn_access" {
  vpc_id = module.vpc.vpc_id
  name = "vpn-sg"

  ingress {
    from_port = 443
    protocol = "UDP"
    to_port = 443
    cidr_blocks = ["0.0.0.0/0"]
    description = "Incoming VPN connection"
  }

  egress {
    from_port = 0
    protocol = "-1"
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_ec2_client_vpn_network_association" "vpn_subnets" {
  count = length(module.vpc.azs)

  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.vpn.id
  subnet_id = module.vpc.public_subnets[0]
  security_groups = [aws_security_group.vpn_access.id]

  lifecycle {
    # The issue why we are ignoring changes is that on every change
    # terraform screws up most of the vpn assosciations
    # see: https://github.com/hashicorp/terraform-provider-aws/issues/14717
    ignore_changes = [subnet_id]
  }
}

resource "aws_ec2_client_vpn_authorization_rule" "vpn_auth_rule" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.vpn.id
  target_network_cidr = module.vpc.cidr
  authorize_all_groups = true
}
