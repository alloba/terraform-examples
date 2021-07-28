#region route_tables
resource "aws_route_table" "public-route-tables" {
  count = length(var.public-subnet-cidrs)
  vpc_id = aws_vpc.vpc.id

  tags = merge(var.additional-tags, { "Name": "${lookup(var.additional-tags, "Name", "untagged")}-public" })
}

resource "aws_route_table" "private-route-tables" {
  count = length(var.private-subnet-cidrs)
  vpc_id = aws_vpc.vpc.id

  tags = merge(var.additional-tags, { "Name": "${lookup(var.additional-tags, "Name", "untagged")}-private" })
}

resource "aws_route_table_association" "public-subnet-routes" {
  count = length(var.public-subnet-cidrs)
  subnet_id      = aws_subnet.public-subnets[count.index].id
  route_table_id = aws_route_table.public-route-tables[count.index].id
}

resource "aws_route_table_association" "private-subnet-routes" {
  count = length(var.private-subnet-cidrs)
  subnet_id      = aws_subnet.private-subnets[count.index].id
  route_table_id = aws_route_table.private-route-tables[count.index].id
}
#endregion route_tables

# region public_access
resource "aws_eip" "nat" {
  count = ! var.enable-public-networking ? 0 : length(var.public-subnet-cidrs)
  vpc = true

  tags = merge(var.additional-tags, {})
}

resource "aws_internet_gateway" "igw" {
  count = var.enable-public-networking ? 1 : 0
  vpc_id = aws_vpc.vpc.id

  tags = merge(var.additional-tags, {})
}

resource "aws_nat_gateway" "ngw" {
  count = ! var.enable-public-networking ? 0 : length(var.public-subnet-cidrs)
  subnet_id     = aws_subnet.public-subnets[count.index].id
  allocation_id = aws_eip.nat[count.index].id

  depends_on = [aws_internet_gateway.igw]
  tags = merge(var.additional-tags, {})
}

resource "aws_route" "public_igw" {
  count = ! var.enable-public-networking ? 0 : length(var.public-subnet-cidrs)
  route_table_id         = aws_route_table.public-route-tables[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw[0].id

}

resource "aws_route" "private_ngw" {
  count = ! var.enable-public-networking ? 0 : length(var.private-subnet-cidrs)
  route_table_id         = aws_route_table.private-route-tables[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.ngw[count.index].id
}
# endregion public_access