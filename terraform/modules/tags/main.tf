/**
 * # TAGS module
 * ----
 */

locals {
  environment = {
    prd = "Production"
    dev = "Development"
    hml = "Homolog"
    stg = "Staging"
  }

  env = {
    prd = "prod"
    dev = "dev"
    hml = "hml"
    stg = "stg"
  }

  common_prefix = "${var.name}-${var.environment}"

  common_tags = merge({
    Name            = local.common_prefix
    CreateAt        = time_static.example.rfc3339
    Product         = var.product
    Environment     = local.environment[var.environment]
    CostCenter      = var.cost_center
    Owner           = var.owner
    PlatformVersion = var.platform_version
    Service         = var.service_name
    Version         = var.service_version
  }, var.additional_tags)
}

resource "time_static" "example" {}

