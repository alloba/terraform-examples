#region -- public-network-setup
resource "aws_internet_gateway" "testing_internet_gateway" {
  # Internet gateway is required to allow traffic to the outside world from the vpc.
  vpc_id = aws_vpc.testing_vpc.id
  tags   = { Name = "${var.environment-name}-internet-gateway" }
}

resource "aws_subnet" "public_subnets" {
  cidr_block = element(var.public-subnets, count.index)
  vpc_id     = aws_vpc.testing_vpc.id
  tags       = { Name = "${var.environment-name}-public-subnet" }
  count      = length(var.public-subnets)
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.testing_vpc.id
  route {
    cidr_block = "0.0.0.0/0" # catch all traffic
    gateway_id = aws_internet_gateway.testing_internet_gateway.id
  }
  tags = { Name = "${var.environment-name}-route-table" }
}

resource "aws_route_table_association" "public_route_table_association" {
  # connect the route table (catch all traffic) to the public subnet.
  route_table_id = aws_route_table.public_route_table.id
  subnet_id      = element(aws_subnet.public_subnets[*].id, count.index)
  count          = length(var.public-subnets)

  depends_on = [aws_route_table.public_route_table, aws_subnet.public_subnets]
}

resource "aws_security_group" "load_balancer_security_group" {
  vpc_id = aws_vpc.testing_vpc.id
  ingress {
    from_port = 80
    protocol = "tcp"
    to_port = 80
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  egress {
    from_port = 0
    protocol = "-1"
    to_port = 0
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = { Name = "${var.environment-name}-lb-security-group" }
}

resource "aws_alb" "load_balancer" {
  name = "${var.environment-name}-alb"
  internal = false
  load_balancer_type = "application"
  subnets = aws_subnet.public_subnets[*].id
  security_groups = [aws_security_group.load_balancer_security_group.id]

  tags = { Name = "${var.environment-name}-load-balancer" }
}

resource "aws_alb_target_group" "lb_target_group" {
  name = "${var.environment-name}-target-group"
  port = 80 # port that receives traffic. So, *incoming* on port 80.
  protocol = "HTTP"
  target_type = "instance" # targets are specified by instance ID.
  vpc_id = aws_vpc.testing_vpc.id

  health_check {
    healthy_threshold   = "2"
    interval            = "300"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = "3"
    path                = "/"
    unhealthy_threshold = "2"
  }

  tags = { Name = "${var.environment-name}-target-group" }
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_alb.load_balancer.id
  port = 80
  default_action {
    type = "forward"
    target_group_arn = aws_alb_target_group.lb_target_group.id
  }
}
#endregion public-network-setup

#region private-network-setup
resource "aws_subnet" "private_subnets" {
  cidr_block = element(var.private-subnets, count.index)
  vpc_id     = aws_vpc.testing_vpc.id
  tags       = { Name = "${var.environment-name}-private-subnet" }
  count      = length(var.public-subnets)
}

resource "aws_eip" "nat-gateway-eip" {
  vpc = true
}

resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat-gateway-eip.id
  subnet_id = aws_subnet.public_subnets[0].id # im hoping i can get away with just the one gateway for however many private subnets...
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.testing_vpc.id
  route {
    cidr_block = "0.0.0.0/0" # catch all traffic
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }
  tags = { Name = "${var.environment-name}-route-table" }
}

resource "aws_route_table_association" "private_route_table_association" {
  # connect the route table (catch all traffic) to the public subnet.
  route_table_id = aws_route_table.private_route_table.id
  subnet_id      = element(aws_subnet.private_subnets[*].id, count.index)
  count          = length(var.private-subnets)
}

resource "aws_security_group" "private_security_group" {
  vpc_id = aws_vpc.testing_vpc.id
  ingress {
    from_port = 80
    protocol = "tcp"
    to_port = 80
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    security_groups = [aws_security_group.load_balancer_security_group.id]
  }
  egress {
    from_port = 0
    protocol = "-1"
    to_port = 0
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = { Name = "${var.environment-name}-lb-security-group" }
}
#endregion private-network-setup