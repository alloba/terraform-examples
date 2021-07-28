output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "public_subnet_id" {
  value = aws_subnet.public-subnets[*].id
}

output "private_subnet_id" {
  value = aws_subnet.private-subnets[*].id
}

output "eip_addresses" {
  value = aws_eip.nat[*].public_ip
}