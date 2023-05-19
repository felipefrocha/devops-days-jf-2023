terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "devopsdays-br"
    workspaces {
      prefix  = "base-infra-"
      project = "juizdefora2023"
    }
  }
}

module "base-infra" {
  source                 = "../../terraform/blueprints/base-infra"
  environment            = var.environment
  region                 = var.region
  project                = var.project
  server_name            = var.server_name
  organization_name      = var.organization_name
  download_certs         = var.download_certs
  hosted_zone            = var.hosted_zone
  route53_by_environment = var.route53_by_environment
  access_key             = var.access_key
  secret_key             = var.secret_key
  token                  = var.token
}
