output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "public_subnet_ids" {
  value = aws_subnet.public-subnets[*].id
}

output "private_subnet_ids" {
  value = aws_subnet.private-subnets[*].id
}

output "eip_addresses" {
  value = aws_eip.nat[*].public_ip
}

output "security_group_egress_all_id" {
  value = aws_security_group.egress-all.id
}

output "security_group_ingress_http_id" {
  value = aws_security_group.http.id
}

output "internet_gateway_id" {
  value = aws_internet_gateway.igw[0].id # there is only ever one, if networking is enabled. if not, this will probably break...
}