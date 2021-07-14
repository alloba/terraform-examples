resource "aws_internet_gateway" "testing_internet_gateway" {
  vpc_id = aws_vpc.testing_vpc.id
  tags   = { Name = "terraform-testing-internet-gateway" }
}

resource "aws_subnet" "testing_public_subnet" {
  cidr_block = "10.0.1.0/25" # subset of the ip addresses defined in the vpc
  vpc_id     = aws_vpc.testing_vpc.id
  tags       = { Name = "terraform-testing-subnet" }
}

resource "aws_route_table" "testing_route_table" {
  # this seems to be very slow to execute in terraform initially? either that or it just breaks outright and is fixed on the next pass through...
  # should look into it more. a quick google didnt do much good.
  vpc_id = aws_vpc.testing_vpc.id
  route {
    cidr_block = "0.0.0.0/0" # catch all traffic
    gateway_id = aws_internet_gateway.testing_internet_gateway.id
  }
  tags = { Name = "terraform-testing-route-table" }
}

resource "aws_route_table_association" "testing_route_table_association" {
  # connect the route table (catch all traffic) to the public subnet.
  route_table_id = aws_route_table.testing_route_table.id
  subnet_id      = aws_subnet.testing_public_subnet.id
}

resource "aws_security_group" "testing_security_group" {
  vpc_id = aws_vpc.testing_vpc.id
  # allow ssh access from all sources.
  ingress {
    from_port   = 22
    protocol    = "tcp"
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  # allow https from all sources
  ingress {
    from_port   = 443
    protocol    = "tcp"
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    protocol    = "tcp"
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  # full outgoing access for internal items
  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "terraform-testing-security-group" }
}