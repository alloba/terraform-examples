resource "aws_subnet" "public-subnets" {
  count             = length(var.public-subnet-cidrs)
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.public-subnet-cidrs[count.index]
  availability_zone = var.availability-zones[count.index]

  tags = merge(var.additional-tags, { "Name" : "${lookup(var.additional-tags, "Name", "untagged")}-public" })

}

resource "aws_subnet" "private-subnets" {
  count      = length(var.private-subnet-cidrs)
  vpc_id     = aws_vpc.vpc.id
  cidr_block = var.private-subnet-cidrs[count.index]

  tags = merge(var.additional-tags, { "Name" : "${lookup(var.additional-tags, "Name", "untagged")}-private" })
}