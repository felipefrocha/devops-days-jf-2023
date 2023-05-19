
output "vpc_main_arn" {
  value = module.vpc.vpc_arn
}
output "vpc_id" {
  value = module.vpc.vpc_id
}
output "vpc_cidr" {
  value = module.vpc.vpc_cidr_block
}
output "private_cidr" {
  value = module.vpc.private_subnets_cidr_blocks[0]
}
output "public_cidr" {
  value = module.vpc.public_subnets_cidr_blocks[0]
}
output "public_subnets_id" {
  value = module.vpc.public_subnets
}
output "private_subnets_id" {
  value = module.vpc.private_subnets
}
output "security_group_ids" {
  value = aws_security_group.this.id
}
output "key_name" {
  value = aws_key_pair.ec2_bastion.key_name
}
# output "lb_arn" {
#   value = aws_lb.adm_lb.arn
# }
# output "lb_zone_id" {
#   value = aws_lb.adm_lb.zone_id
# }
# output "lb_dns_name" {
#   value = aws_lb.adm_lb.dns_name
# }
output "sg_lb_adm" {
  value = aws_security_group.adm_lb_sg.id
}
output "private_key" {
  value     = module.private_key.private_key_pem
  sensitive = true
}
output "root_ca_cert_pem" {
  value     = module.root_tls_self_signed_ca.ca_cert_pem
  sensitive = true
}
output "leaf_cert_pem" {
  value     = module.leaf_tls_self_signed_cert.leaf_cert_pem
  sensitive = true

}
output "leaf_key_pem" {
  value     = module.leaf_tls_self_signed_cert.leaf_private_key_pem
  sensitive = true
}
# output "domain" {
#   value = trimsuffix(local.domain, ".")
# }
# output "acm_certificate_arn" {
#   value = aws_acm_certificate.cert.arn
# }





















