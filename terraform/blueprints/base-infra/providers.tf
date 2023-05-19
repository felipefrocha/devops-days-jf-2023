# provider "vault" {
#   address = var.vault_addr
#   token   = var.vault_token
# }

# data "vault_aws_access_credentials" "creds" {
#   type    = "sts"
#   backend = "devopsdays"
#   role    = "aws-admin"
# }

provider "aws" {
  region     = var.region
  access_key = var.access_key
  secret_key = var.secret_key
  token      = var.token
  # access_key = data.vault_aws_access_credentials.creds.access_key
  # secret_key = data.vault_aws_access_credentials.creds.secret_key
  # token      = data.vault_aws_access_credentials.creds.security_token
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">4.40"
    }
    vault = {
      source  = "hashicorp/vault"
      version = ">2.20.0"
    }
  }
}
