terraform {
  cloud {
    organization = "kosta-mlops"
    workspaces {
      name = "populare"
    }
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "us-east-2"
}

#module "eks" {
#  source  = "terraform-aws-modules/eks/aws"
#  version = "~> 18.0"
#
#  cluster_name    = "populare"
#  cluster_version = "1.22"
#
#  cluster_addons = {
#    coredns = {
#      resolve_conflicts = "OVERWRITE"
#    }
#    kube-proxy = {}
#    vpc-cni = {
#      resolve_conflicts = "OVERWRITE"
#    }
#  }
#
#  vpc_id     = module.vpc.id
#  subnet_ids = module.vpc.public_subnets
#
#  # Self Managed Node Group(s)
#  self_managed_node_group_defaults = {
#    instance_type                          = "m6i.large"
#    update_launch_template_default_version = true
#    iam_role_additional_policies = [
#      "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
#    ]
#  }
#
#  self_managed_node_groups = {
#    one = {
#      name         = "mixed-1"
#      max_size     = 5
#      desired_size = 2
#
#      use_mixed_instances_policy = true
#      mixed_instances_policy = {
#        instances_distribution = {
#          on_demand_base_capacity                  = 0
#          on_demand_percentage_above_base_capacity = 10
#          spot_allocation_strategy                 = "capacity-optimized"
#        }
#
#        override = [
#          {
#            instance_type     = "m5.large"
#            weighted_capacity = "1"
#          },
#          {
#            instance_type     = "m6i.large"
#            weighted_capacity = "2"
#          },
#        ]
#      }
#    }
#  }
#
#  # EKS Managed Node Group(s)
#  eks_managed_node_group_defaults = {
#    disk_size      = 50
#    instance_types = ["m6i.large", "m5.large", "m5n.large", "m5zn.large"]
#  }
#
#  eks_managed_node_groups = {
#    blue = {}
#    green = {
#      min_size     = 1
#      max_size     = 10
#      desired_size = 1
#
#      instance_types = ["t3.large"]
#      capacity_type  = "SPOT"
#    }
#  }
#
#  # Fargate Profile(s)
#  fargate_profiles = {
#    default = {
#      name = "default"
#      selectors = [
#        {
#          namespace = "default"
#        }
#      ]
#    }
#  }
#
#  # aws-auth configmap
#  manage_aws_auth_configmap = true
#
#  aws_auth_roles = [
#    {
#      rolearn  = "arn:aws:iam::66666666666:role/role1"
#      username = "role1"
#      groups   = ["system:masters"]
#    },
#  ]
#
#  aws_auth_users = [
#    {
#      userarn  = "arn:aws:iam::66666666666:user/user1"
#      username = "user1"
#      groups   = ["system:masters"]
#    },
#    {
#      userarn  = "arn:aws:iam::66666666666:user/user2"
#      username = "user2"
#      groups   = ["system:masters"]
#    },
#  ]
#
#  aws_auth_accounts = [
#    "777777777777",
#    "888888888888",
#  ]
#
#  tags = {
#    Environment = "dev"
#    Terraform   = "true"
#  }
#}
