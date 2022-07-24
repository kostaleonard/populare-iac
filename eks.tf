module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 18.0"

  cluster_name    = "populare-cluster"
  cluster_version = "1.22"

#  cluster_addons = {
#    coredns = {
#      resolve_conflicts = "OVERWRITE"
#    }
#    kube-proxy = {}
#    vpc-cni = {
#      resolve_conflicts = "OVERWRITE"
#    }
#  }

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.public_subnets

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
