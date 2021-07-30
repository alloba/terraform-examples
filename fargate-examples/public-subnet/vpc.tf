resource "aws_vpc" "vpc" {
  cidr_block = var.vpc-cidr-range

  tags = merge(var.additional-tags, {})
}

resource "aws_subnet" "public-subnets" {
  count             = length(var.public-subnet-cidrs)
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.public-subnet-cidrs[count.index]
  availability_zone = var.availability-zones[count.index]

  tags = merge(var.additional-tags, { "Name" : "${lookup(var.additional-tags, "Name", "untagged")}-public" })

}
