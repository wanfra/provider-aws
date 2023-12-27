terraform {
  cloud {
    organization = "wanfracloud"

    workspaces {
      name = "wanfracloud"
    }
  }
}

provider "aws" {
    region = "eu-west-3"
    secret_key = var.AWS_SECRET_KEY
    access_key = var.AWS_ACCESS_KEY
}

