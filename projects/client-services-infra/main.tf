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
module "base-infra"{

}
