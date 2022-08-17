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

#data "template_file" "bootstrap" {
#  template = file("${path.module}/bootstrap.tpl")
#  vars = {
#    cluster_name        = var.cluster_name
#    cluster_auth_base64 = module.eks.cluster_certificate_authority_data
#    endpoint            = module.eks.cluster_endpoint
#  }
#}
#
#resource "aws_ami" "eks_node" {
#  name                = "custom_ami"
#}

#data "aws_ami" "eks_node" {
#  # Use your AWS ID here; not secret.
#  owners      = ["890362829064"]
#  most_recent = true
#
#  filter {
#    name   = "name"
#    values = ["amazon-eks-node-${module.eks.cluster_version}-v20220815"]
#  }
#}

#resource "aws_launch_template" "nodes" {
#  name = "modified_sysctl"
#  image_id = aws_ami.eks_node.id
#  user_data = base64encode(data.template_file.bootstrap.rendered)
#}
