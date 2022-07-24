module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 18.0"

  cluster_name    = var.cluster_name
  cluster_version = "1.22"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.public_subnets

  node_security_group_additional_rules = {
    egress_sql = {
      description      = "Node to SQL"
      protocol         = "tcp"
      from_port        = 3306
      to_port          = 3306
      type             = "egress"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
  }

  eks_managed_node_groups = {
    populare-node-group = {
      desired_capacity = 1
      max_capacity     = 3
      min_capacity     = 1

      instance_type = "m5.large"
    }
  }

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}

#resource "kubernetes_secret" "db-certs" {
#  metadata {
#    name = "db-certs"
#  }
#
#  data = {
#    db-uri = "mysql+pymysql://${var.db_username}:${var.db_password}@${aws_db_instance.populare.address}/${aws_db_instance.populare.db_name}"
#  }
#}
