# region security-groups
resource "aws_security_group" "http" {
  description = "HTTP traffic"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.additional-tags, { "Name" : "${lookup(var.additional-tags, "Name", "untagged")}-http" })
}

resource "aws_security_group" "https" {
  description = "HTTPS traffic"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.additional-tags, { "Name" : "${lookup(var.additional-tags, "Name", "untagged")}-https" })
}

resource "aws_security_group" "egress-all" {
  description = "Allow all outbound traffic"
  vpc_id      = aws_vpc.vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.additional-tags, { "Name" : "${lookup(var.additional-tags, "Name", "untagged")}-egress-all" })
}
# endregion security-groups

# region routing
resource "aws_route_table" "public-route-tables" {
  count  = length(var.public-subnet-cidrs)
  vpc_id = aws_vpc.vpc.id

  tags = merge(var.additional-tags, { "Name" : "${lookup(var.additional-tags, "Name", "untagged")}-public" })
}

resource "aws_route_table_association" "public-subnet-routes" {
  count          = length(var.public-subnet-cidrs)
  subnet_id      = aws_subnet.public-subnets[count.index].id
  route_table_id = aws_route_table.public-route-tables[count.index].id
}

resource "aws_internet_gateway" "igw" {
  count  = 1
  vpc_id = aws_vpc.vpc.id

  tags = merge(var.additional-tags, {})
}

resource "aws_route" "public_igw" {
  count                  = length(var.public-subnet-cidrs)
  route_table_id         = aws_route_table.public-route-tables[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw[0].id

}
# endregion routing

# region load-balancer
resource "aws_lb_target_group" "terraform-example-fargate-lb-target" {
  name        = "fargate-test-http"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.vpc.id

  health_check {
    enabled = true
    path    = "/"
  }

  depends_on = [aws_alb.terraform-ex-fargate-aws-alb]
}

resource "aws_alb" "terraform-ex-fargate-aws-alb" {
  name               = "terraform-ex-fargate-aws-alb"
  internal           = false
  load_balancer_type = "application"

  subnets = aws_subnet.public-subnets[*].id

  security_groups = [
    aws_security_group.http.id,
    aws_security_group.https.id,
    aws_security_group.egress-all.id
  ]

  depends_on = [aws_internet_gateway.igw]
}

resource "aws_alb_listener" "terraform-example-fargate-alb-listener" {
  load_balancer_arn = aws_alb.terraform-ex-fargate-aws-alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.terraform-example-fargate-lb-target.arn
  }
}
# endregion load-balancer

