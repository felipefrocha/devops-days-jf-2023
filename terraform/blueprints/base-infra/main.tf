/**
 * # VPC and Base infra configuration
 * ----
 * ## Base Infrastructure provisioning:
 * - Main rules
 * - Security groups
 * - Key Pairs
 * - Structure Roles
 * - Certifications
 *
 * ----
 */

/**
 * Tag resources
 */

module "tags" {
  source           = "../../modules/tags"
  environment      = var.environment
  name             = "base-infra"
  owner            = "felipefrocha"
  service_name     = "shared-infra"
  product          = var.project
  platform_version = "v0.1.0"

}


/**
 * Create VPC 
 */
module "vpc" {
  source              = "../../modules/vpc"
  region              = var.region
  project             = var.project
  environment         = local.env[var.environment]
  vpc_main_cidr_block = format("172.1%d.0.0/16", var.environment == "dev" ? 0 : var.environment == "stg" ? 1 : 2)
  subnet_size         = 4
  azs                 = try(slice(data.aws_availability_zones.available.names, 0, 3), [])
  tags                = local.tags
}

/**
 * Keys to be manage
 */

module "private_key" {
  # Module Source
  source = "../../modules/tls"

  create_key            = true
  name                  = "tf_mkr"
  rsa_bits              = "2048"
  environment           = local.env[var.environment]
  project               = var.project
  common_name           = ""
  organization_name     = ""
  validity_period_hours = ""
  create_tls            = false
  download_certs        = var.download_certs
}

resource "aws_key_pair" "ec2_bastion" {
  key_name_prefix = "terraform_key_${local.env[var.environment]}"
  public_key      = module.private_key.public_key_openssh
}

/**
 * Create TLS Bastion Vault Consul
 */

module "root_tls_self_signed_ca" {
  source            = "../../modules/tls"
  project           = var.project
  environment       = local.env[var.environment]
  name              = format("%s-root", "tls")
  ca_common_name    = local.common_name
  organization_name = var.organization_name
  common_name       = local.common_name
  download_certs    = var.download_certs

  validity_period_hours = "8760"

  ca_allowed_uses = [
    "cert_signing",
    "key_encipherment",
    "digital_signature",
    "server_auth",
    "client_auth",
  ]
}

module "leaf_tls_self_signed_cert" {
  source      = "../../modules/tls"
  project     = var.project
  environment = local.env[var.environment]

  name              = format("%s-leaf", "tls")
  organization_name = var.organization_name
  common_name       = local.common_name
  ca_override       = true
  ca_key_override   = module.root_tls_self_signed_ca.ca_private_key_pem
  ca_cert_override  = module.root_tls_self_signed_ca.ca_cert_pem
  download_certs    = var.download_certs

  validity_period_hours = "8760"

  dns_names = [
    "localhost",
    "*.node.consul",
    "*.service.consul",
    "server.dc1.consul",
    "*.dc1.consul",
    "server.${var.server_name}.consul",
    "*.${var.server_name}.consul",
  ]

  ip_addresses = [
    "0.0.0.0",
    "127.0.0.1",
  ]

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
    "client_auth",
  ]
}

/**
 * Route 53
 */

# resource "aws_route53_zone" "this" {
#   name = local.domain
# }

/**
 * Certificado de gamma-isa.com.br
 */
# resource "aws_acm_certificate" "cert" {
#   domain_name               = local.common_name
#   validation_method         = "DNS"
#   subject_alternative_names = [format("*.%s", local.common_name)]
#   tags = merge({
#     Name = local.common_name
#   }, local.tags)
# }

# resource "aws_route53_record" "cert_validation" {
#   for_each = {
#     for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
#       name    = dvo.resource_record_name
#       record  = dvo.resource_record_value
#       type    = dvo.resource_record_type
#       zone_id = aws_route53_zone.this.zone_id
#     }
#   }

#   allow_overwrite = true
#   name            = each.value.name
#   records         = [each.value.record]
#   ttl             = 60
#   type            = each.value.type
#   zone_id         = each.value.zone_id
# }

# resource "aws_acm_certificate_validation" "cert" {
#   certificate_arn         = aws_acm_certificate.cert.arn
#   validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
# }

/**
 * Main Securities Groups
 */
resource "aws_security_group" "this" {

  name        = format("%s-ssh-private-%s", var.project, local.env[var.environment])
  vpc_id      = module.vpc.vpc_id
  description = "SG For private network"
  tags = merge(
    {
      "Name" = format("%s-ssh-private-%s", var.project, local.env[var.environment])
    },
    local.tags
  )
  ingress {
    from_port   = 0
    description = "Client Ingress"
    cidr_blocks = [
    "0.0.0.0/0"]
    protocol = "-1"
    to_port  = 0
  }
  ingress {
    from_port   = 80
    description = "Client Ingress"
    cidr_blocks = module.vpc.private_subnets_cidr_blocks
    protocol    = "tcp"
    to_port     = 80
  }
  ingress {
    from_port   = 443
    description = "Secured Client Ingress"
    cidr_blocks = module.vpc.private_subnets_cidr_blocks
    protocol    = "tcp"
    to_port     = 443
  }
  ingress {
    from_port   = 22
    description = "SSH Ingress"
    cidr_blocks = module.vpc.private_subnets_cidr_blocks
    protocol    = "tcp"
    to_port     = 22
  }

  egress {
    from_port   = 0
    description = "All tranfic out permited"
    cidr_blocks = [
    "0.0.0.0/0"]
    ipv6_cidr_blocks = [
    "::/0"]
    protocol = "-1"
    to_port  = 0
  }
}

resource "aws_security_group" "adm_lb_sg" {

  vpc_id = module.vpc.vpc_id
  name   = "${var.project}-sg-admin-lb"

  ingress {
    description = "HTTP Communication for bastion"
    protocol    = "TCP"
    cidr_blocks = [
    "0.0.0.0/0"]
    from_port = 80
    to_port   = 80
  }
  ingress {
    description = "HTTPS Communication for bastion"
    protocol    = "TCP"
    cidr_blocks = [
    "0.0.0.0/0"]
    from_port = 443
    to_port   = 443
  }

  egress {
    description = "Web Communication"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [
    "0.0.0.0/0"]
  }

  tags = merge({
    Name = "sg-1"
  }, local.tags)

}

/**
 * Load Balancer Application - Destination to main routes
 */
resource "aws_lb" "adm_lb" {
  name               = format("%s-alb-%s", var.project, local.env[var.environment])
  internal           = false
  load_balancer_type = "application"
  security_groups = [
  aws_security_group.adm_lb_sg.id]
  subnets = module.vpc.public_subnets

  enable_deletion_protection = false
  tags                       = local.tags
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.adm_lb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate_validation.cert.certificate_arn
  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Sorry =(, this subdomain is not available! (@_@)"
      status_code  = "404"
    }
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.adm_lb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}


