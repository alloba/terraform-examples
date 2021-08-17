data "aws_vpc" "vpc-host" {
  tags = {
    environment: "infra-usw2"
    Name: "infra"
  }
}
