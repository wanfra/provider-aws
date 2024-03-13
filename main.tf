terraform {
  cloud {
    organization = "wanfracloud"

    workspaces {
      name = "provider-aws"
    }
  }
}

provider "aws" {
    region = "eu-west-3"
    secret_key = var.AWS_SECRET_KEY
    access_key = var.AWS_ACCESS_KEY
}

