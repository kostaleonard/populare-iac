terraform {
  cloud {
    organization = "kosta-mlops"
    workspaces {
      name = "populare-kubernetes"
    }
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.12.1"
    }
  }
  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "us-east-2"
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.default.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.default.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.default.token
}

data "terraform_remote_state" "populare_workspace_state" {
  backend = "remote"
  config = {
    organization = "kosta-mlops"
    workspaces = {
      name    = "populare"
    }
  }
}

data "aws_eks_cluster" "default" {
  name = data.terraform_remote_state.populare_workspace_state.outputs.cluster_name
}

data "aws_eks_cluster_auth" "default" {
  name = data.terraform_remote_state.populare_workspace_state.outputs.cluster_name
}
