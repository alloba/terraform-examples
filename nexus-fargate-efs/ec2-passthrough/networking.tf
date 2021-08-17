resource "aws_security_group" "ec2-sg" {
  description = "ECS SG Nexus"
  vpc_id = data.aws_vpc.vpc-host.id
  tags = merge(local.common_tags, {})
}

resource "aws_security_group_rule" "ingress-all" {
  from_port = 0
  protocol = "-1"
  security_group_id = aws_security_group.ec2-sg.id
  to_port = 0
  type = "ingress"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "egress-all" {
  from_port = 0
  protocol = "-1"
  security_group_id = aws_security_group.ec2-sg.id
  to_port = 0
  type = "egress"
  cidr_blocks = ["0.0.0.0/0"]
}

data "aws_subnet" "public-west-a" {
  tags = {
    Name: "Infrastructure Public A"
    environment: "infra-usw2"
  }
}
