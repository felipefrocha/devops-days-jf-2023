terraform {
  required_version = "> 0.14.0"
}

locals {
  ca_cert = chomp(var.ca_cert_override == "" ? element(concat(tls_self_signed_cert.ca.*.cert_pem, tolist([""])), 0) : var.ca_cert_override)
}
resource "random_id" "name" {
  count = var.create_tls || var.create_key ? 1 : 0

  byte_length = 4
  prefix      = format("%s-", var.name)
}

/**
 * SSH KEY module
 */

resource "tls_private_key" "key" {
  count = var.create_key ? 1 : 0

  algorithm   = var.algorithm
  rsa_bits    = var.rsa_bits
  ecdsa_curve = var.ecdsa_curve
}

resource "null_resource" "download_private_key" {
  count = var.create_key ? 1 : 0

  provisioner "local-exec" {
    command = format("echo '%s' > %s.key.pem && chmod %s %s.key.pem", tls_private_key.key[0].private_key_pem, random_id.name[0].hex, var.permissions, random_id.name[0].hex)
  }
}


/**
 * TLS module
 */


resource "tls_private_key" "ca" {
  count = var.create_tls && !var.ca_override ? 1 : 0

  algorithm   = var.algorithm
  ecdsa_curve = var.ecdsa_curve
  rsa_bits    = var.rsa_bits
}

resource "tls_self_signed_cert" "ca" {
  count = var.create_tls && !var.ca_override ? 1 : 0

  # key_algorithm     = tls_private_key.ca[0].algorithm
  private_key_pem   = var.ca_key_override == "" ? tls_private_key.ca[0].private_key_pem : var.ca_key_override
  is_ca_certificate = true

  validity_period_hours = var.validity_period_hours
  allowed_uses          = var.ca_allowed_uses

  subject {
    common_name  = var.ca_common_name
    organization = var.organization_name
  }
}

resource "tls_private_key" "leaf" {
  count = var.create_tls ? 1 : 0

  algorithm   = var.algorithm
  ecdsa_curve = var.ecdsa_curve
  rsa_bits    = var.rsa_bits
}

resource "tls_cert_request" "leaf" {
  count = var.create_tls ? 1 : 0

  # key_algorithm   = tls_private_key.leaf[0].algorithm
  private_key_pem = tls_private_key.leaf[0].private_key_pem

  dns_names    = var.dns_names
  ip_addresses = var.ip_addresses

  subject {
    common_name  = var.common_name
    organization = var.organization_name
  }
}

resource "tls_locally_signed_cert" "leaf" {
  count = var.create_tls ? 1 : 0

  cert_request_pem = tls_cert_request.leaf[0].cert_request_pem

  # ca_key_algorithm   = !var.ca_override ? element(concat(tls_private_key.ca[0].*.algorithm, tolist([""])), 0) : var.algorithm
  ca_private_key_pem = var.ca_key_override == "" ? element(concat(tls_private_key.ca[0].*.private_key_pem, tolist([""])), 0) : var.ca_key_override
  ca_cert_pem        = var.ca_cert_override == "" ? element(concat(tls_self_signed_cert.ca.*.cert_pem, tolist([""])), 0) : var.ca_cert_override

  validity_period_hours = var.validity_period_hours
  allowed_uses          = var.allowed_uses
}

resource "null_resource" "download_ca_cert" {
  count = var.create_tls && var.download_certs ? 1 : 0

  # Write the PEM-encoded CA certificate public key to this path (e.g. /etc/tls/ca.crt.pem).
  provisioner "local-exec" {
    command = format("echo '%s' > %s-ca.crt.pem && chmod %s '%s-ca.crt.pem'", local.ca_cert, random_id.name[0].hex, var.permissions, random_id.name[0].hex)
  }
}

resource "null_resource" "download_leaf_cert" {
  count = var.create_tls && var.download_certs ? 1 : 0

  # Write the PEM-encoded certificate public key to this path (e.g. /etc/tls/leaf.crt.pem).
  provisioner "local-exec" {
    command = format("echo '%s' > %s-leaf.crt.pem && chmod %s '%s-leaf.crt.pem'", chomp(tls_locally_signed_cert.leaf[0].cert_pem), random_id.name[0].hex, var.permissions, random_id.name[0].hex)
  }
}

resource "null_resource" "download_leaf_private_key" {
  count = var.create_tls && var.download_certs ? 1 : 0

  # Write the PEM-encoded leaf certificate private key to this path (e.g. /etc/tls/leaf.key.pem).
  provisioner "local-exec" {
    command = format("echo '%s' > %s-leaf.key.pem && chmod %s '%s-leaf.key.pem'", chomp(tls_private_key.leaf[0].private_key_pem), random_id.name[0].hex, var.permissions, random_id.name[0].hex)
  }
}
