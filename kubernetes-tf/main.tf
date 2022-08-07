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
    tfe = {
      source = "hashicorp/tfe"
      version = "0.35.0"
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

data "tfe_outputs" "populare_workspace_outputs" {
  organization = "kosta-mlops"
  workspace = "populare"
}

data "aws_eks_cluster" "default" {
  name = data.tfe_outputs.populare_workspace_outputs.values.cluster_name
}

data "aws_eks_cluster_auth" "default" {
  name = data.tfe_outputs.populare_workspace_outputs.values.cluster_name
}
