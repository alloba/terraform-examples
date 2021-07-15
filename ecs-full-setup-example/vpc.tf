resource "aws_vpc" "testing_vpc" {
  cidr_block           = var.vpc-cidr
  enable_dns_support   = true # both are required for dns anything in a vpc.... which makes it sound like you would literally always want this, but i dunno.
  enable_dns_hostnames = true

  tags = { Name = "${var.environment-name}-vpc" }
}