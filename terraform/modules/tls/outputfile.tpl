# ------------------------------------------------------------------------------
# ${name} TLS Self Signed Certs
# ------------------------------------------------------------------------------

The below private keys and self signed TLS certificates have been generated.

- CA certificate: ${ca_cert}
- Leaf certificate: ${leaf_cert}

${download}

## Helper

- ${ca_cert_file}
- ${leaf_cert_file}
- ${leaf_cert_key}

  # View your certs
  $ openssl x509 -text -in ${ca_cert_file}
  $ openssl x509 -text -in ${leaf_cert_file}

  # Verify root CA
  $ openssl verify -CAfile ${ca_cert_file} \\
    ${leaf_cert_file}"

