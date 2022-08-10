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
      version = "= 3.32"
    }
  }
  required_version = "= 0.14.10"
}

provider "aws" {
  region = "us-east-2"
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
