terraform {
  cloud {
    organization = "kosta-mlops"
    workspaces {
      name = "populare-vpn"
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

# TODO may need remote state
#data "terraform_remote_state" "populare_workspace_state" {
#  backend = "remote"
#  config = {
#    organization = "kosta-mlops"
#    workspaces = {
#      name    = "populare"
#    }
#  }
#}
