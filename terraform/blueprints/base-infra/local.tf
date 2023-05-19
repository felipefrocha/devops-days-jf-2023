locals {
  # Environment's acronym
  env = {
    prd = "prd"
    dev = "dev"
    hml = "hml"
    stg = "stg"
  }
  # Environment's full name
  environment = {
    prd = "Production"
    dev = "Development"
    hml = "Homologation"
    stg = "Staging"
  }
  # Tags to complement all Resources
  tags = module.tags.common_tags

  domain      = var.route53_by_environment ? format("%s.%s.", local.env[var.environment], var.hosted_zone) : format("%s.", var.hosted_zone)
  common_name = var.route53_by_environment ? format("%s.%s", local.env[var.environment], var.hosted_zone) : var.hosted_zone
}
