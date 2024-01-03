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
    secret_key = hXQcfGYSzVEpC5CKlspkK2GoqdQZIsGLij4Mn+JD
    access_key = AKIA3FWI6FVRYTFQQCEP
}

