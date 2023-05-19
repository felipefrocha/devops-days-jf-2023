output "vpc_arn" {
  value = aws_vpc.main.arn
}

output "vpc_cidr_block" {
  value = aws_vpc.main.cidr_block
}
output "private_subnets_cidr_blocks" {
  value = [for k, v in aws_subnet.privates : v.cidr_block]
}

output "public_subnets_cidr_blocks" {
  value = [for k, v in aws_subnet.publics : v.cidr_block]
}

output "public_subnets" {
  value = [for k, v in aws_subnet.publics : v.id]
}

output "private_subnets" {
  value = [for k, v in aws_subnet.privates : v.id]
}

output "vpc_id" {
  value = aws_vpc.main.id
}
