module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 18.29"

  cluster_name    = var.cluster_name
  cluster_version = "1.22"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = [module.vpc.public_subnets[0], module.vpc.public_subnets[1], module.vpc.private_subnets[0], module.vpc.private_subnets[1]]

  node_security_group_additional_rules = {
    ingress_4443_from_control_plane = {
      # This is important for Kubernetes internals such as the metrics server
      # to reach the cluster nodes. See this comment: https://github.com/kubernetes-sigs/metrics-server/issues/1024#issuecomment-1129914389
      description                   = "Cluster API to Nodegroup for metrics server"
      protocol                      = "-1"
      from_port                     = 0
      to_port                       = 4443
      type                          = "ingress"
      source_cluster_security_group = true
    }

    egress_sql = {
      description      = "Node to SQL"
      protocol         = "tcp"
      from_port        = 3306
      to_port          = 3306
      type             = "egress"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }

    ingress_icmp_from_bulwark = {
      description              = "ICMP from bulwark"
      protocol                 = "icmp"
      from_port                = -1
      to_port                  = -1
      type                     = "ingress"
      source_security_group_id = aws_security_group.bulwark.id
    }

    ingress_all_ports_from_bulwark = {
      description              = "All incoming ports from bulwark"
      protocol                 = "-1"
      from_port                = 0
      to_port                  = 0
      type                     = "ingress"
      source_security_group_id = aws_security_group.bulwark.id
    }
  }

  eks_managed_node_groups = {
    populare-node-group = {
      desired_size  = 2
      min_size      = 2
      max_size      = 2
      subnet_ids    = [module.vpc.private_subnets[0], module.vpc.private_subnets[1]]
      instance_type = "m5.large"
    }
  }

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}
