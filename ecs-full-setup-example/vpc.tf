resource "aws_vpc" "testing_vpc" {
  cidr_block           = "10.0.0.0/23" # 10.0.0.0 -> 10.0.1.255 -- 512 possible IPs
  enable_dns_support   = true          # both are required for dns anything in a vpc.... which makes it sound like you would literally always want this, but i dunno.
  enable_dns_hostnames = true

  tags = { Name = "${var.environment-name}-vpc" }
}