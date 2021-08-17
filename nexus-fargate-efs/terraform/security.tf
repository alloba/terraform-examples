resource "aws_security_group" "ecs-sg" {
  description = "ECS SG Nexus"
  vpc_id = data.aws_vpc.vpc-host.id
  tags = merge(local.common_tags, {})
}

resource "aws_security_group_rule" "ecs-http-ingress" {
  from_port = 80
  protocol = "tcp"
  security_group_id = aws_security_group.ecs-sg.id
  to_port = 80
  type = "ingress"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "ecs-http-custom-ingress" {
  from_port = 8081
  protocol = "tcp"
  security_group_id = aws_security_group.ecs-sg.id
  to_port = 8081
  type = "ingress"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "ecs-nfs-ingress" {
  from_port = 2049
  protocol = "tcp"
  security_group_id = aws_security_group.ecs-sg.id
  to_port = 2049
  type = "ingress"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "ecs-egress-all" {
  from_port = 0
  protocol = "-1"
  security_group_id = aws_security_group.ecs-sg.id
  to_port = 0
  type = "egress"
  cidr_blocks = ["0.0.0.0/0"]
}


resource "aws_security_group" "efs-sg" {
  description = "EFS SG Nexus"
  vpc_id = data.aws_vpc.vpc-host.id
  tags = merge(local.common_tags, {})
}

resource "aws_security_group_rule" "efs-egress-all" {
  from_port = 0
  protocol = "-1"
  security_group_id = aws_security_group.efs-sg.id
  to_port = 0
  type = "egress"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "efs-ingress-nft" {
  from_port = 2049
  protocol = "tcp"
  security_group_id = aws_security_group.efs-sg.id
  to_port = 2049
  type = "ingress"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "efs-ingress-encrypt" {
  from_port = 2999
  protocol = "tcp"
  security_group_id = aws_security_group.efs-sg.id
  to_port = 2999
  type = "ingress"
  cidr_blocks = ["0.0.0.0/0"]
}


resource "aws_security_group" "lb-nexus" {
  description = "LB SG Nexus"
  vpc_id = data.aws_vpc.vpc-host.id
  tags = merge(local.common_tags, {})
}

resource "aws_security_group_rule" "lb-egress-all" {
  from_port = 0
  protocol = "-1"
  security_group_id = aws_security_group.lb-nexus.id
  to_port = 0
  type = "egress"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "lb-ingress-all" {
  from_port = 0
  protocol = "-1"
  security_group_id = aws_security_group.lb-nexus.id
  to_port = 0
  type = "ingress"
  cidr_blocks = ["0.0.0.0/0"]
}
