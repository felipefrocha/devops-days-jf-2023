output "algorithm" {
  value = element(concat(tls_private_key.key.*.algorithm, [""]), 0) # TODO: Workaround for issue #11210
}

output "private_key_pem" {
  value = element(concat(tls_private_key.key.*.private_key_pem, [""]), 0) # TODO: Workaround for issue #11210
}

output "private_key_name" {
  value = element(concat(random_id.name.*.hex, [""]), 0) # TODO: Workaround for issue #11210
}

output "private_key_filename" {
  value = element(
    concat(formatlist("%s.key.pem", random_id.name.*.hex), [""]),
    0,
  )
}

output "public_key_pem" {
  value = element(concat(tls_private_key.key.*.public_key_pem, [""]), 0) # TODO: Workaround for issue #11210
}

output "public_key_openssh" {
  value = element(concat(tls_private_key.key.*.public_key_openssh, [""]), 0) # TODO: Workaround for issue #11210
}



output "README" {
  value = templatefile("${path.module}/outputfile.tpl",

    {
      name           = var.name
      ca_cert        = element(concat(formatlist("%s-ca", random_id.name.*.hex), tolist([""])), 0)
      leaf_cert      = element(concat(formatlist("%s-leaf", random_id.name.*.hex), tolist([""])), 0)
      download       = var.download_certs ? "The below certificates and private key have been downloaded locally with the file permissions updated appropriately." : "Certs were not downloaded locally. set \"download_certs\" to true to download."
      ca_cert_file   = element(concat(formatlist("%s-ca.crt.pem", random_id.name.*.hex), tolist([""])), 0)
      leaf_cert_file = element(concat(formatlist("%s-leaf.crt.pem", random_id.name.*.hex), tolist([""])), 0)
      leaf_cert_key  = element(concat(formatlist("%s-leaf.key.pem", random_id.name.*.hex), tolist([""])), 0)
  })
}


# CA - TLS private key
output "ca_private_key_pem" {
  value = chomp(element(concat(tls_private_key.ca.*.private_key_pem, tolist([""])), 0)) # TODO: Workaround for issue #11210
}

output "ca_public_key_pem" {
  value = chomp(element(concat(tls_private_key.ca.*.public_key_pem, tolist([""])), 0)) # TODO: Workaround for issue #11210
}

output "ca_public_key_openssh" {
  value = chomp(element(concat(tls_private_key.ca.*.public_key_openssh, tolist([""])), 0)) # TODO: Workaround for issue #11210
}

# CA - TLS self signed cert
output "ca_cert_name" {
  value = element(concat(formatlist("%s-ca", random_id.name.*.hex), tolist([""])), 0) # TODO: Workaround for issue #11210
}

output "ca_cert_filename" {
  value = element(concat(formatlist("%s-ca.crt.pem", random_id.name.*.hex), tolist([""])), 0) # TODO: Workaround for issue #11210
}

output "ca_cert_pem" {
  value = chomp(element(concat(tls_self_signed_cert.ca.*.cert_pem, tolist([""])), 0)) # TODO: Workaround for issue #11210
}

output "ca_cert_validity_start_time" {
  value = element(concat(tls_self_signed_cert.ca.*.validity_start_time, tolist([""])), 0) # TODO: Workaround for issue #11210
}

output "ca_cert_validity_end_time" {
  value = element(concat(tls_self_signed_cert.ca.*.validity_end_time, tolist([""])), 0) # TODO: Workaround for issue #11210
}

# Leaf - TLS private key
output "leaf_private_key_pem" {
  value = chomp(element(concat(tls_private_key.leaf.*.private_key_pem, tolist([""])), 0)) # TODO: Workaround for issue #11210
}

output "leaf_private_key_filename" {
  value = element(concat(formatlist("%s-leaf.key.pem", random_id.name.*.hex), tolist([""])), 0) # TODO: Workaround for issue #11210
}

output "leaf_public_key_pem" {
  value = chomp(element(concat(tls_private_key.leaf.*.public_key_pem, tolist([""])), 0)) # TODO: Workaround for issue #11210
}

output "leaf_public_key_openssh" {
  value = chomp(element(concat(tls_private_key.leaf.*.public_key_openssh, tolist([""])), 0)) # TODO: Workaround for issue #11210
}

# Leaf - TLS cert request
output "leaf_cert_request_pem" {
  value = chomp(element(concat(tls_cert_request.leaf.*.cert_request_pem, tolist([""])), 0)) # TODO: Workaround for issue #11210
}

# Leaf - TLS locally signed cert
output "leaf_cert_name" {
  value = element(concat(formatlist("%s-leaf", random_id.name.*.hex), tolist([""])), 0) # TODO: Workaround for issue #11210
}

output "leaf_cert_filename" {
  value = element(concat(formatlist("%s-leaf.crt.pem", random_id.name.*.hex), tolist([""])), 0) # TODO: Workaround for issue #11210
}

output "leaf_cert_pem" {
  value = chomp(element(concat(tls_locally_signed_cert.leaf.*.cert_pem, tolist([""])), 0)) # TODO: Workaround for issue #11210
}

output "leaf_cert_validity_start_time" {
  value = element(concat(tls_locally_signed_cert.leaf.*.validity_start_time, tolist([""])), 0) # TODO: Workaround for issue #11210
}

output "leaf_cert_validity_end_time" {
  value = element(concat(tls_locally_signed_cert.leaf.*.validity_end_time, tolist([""])), 0) # TODO: Workaround for issue #11210
}
