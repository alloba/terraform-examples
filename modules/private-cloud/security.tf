
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

//resource "aws_security_group" "api-ingress" {
//  name        = "api_ingress"
//  description = "Allow ingress to API"
//  vpc_id      = aws_vpc.vpc.id
//
//  ingress {
//    from_port   = 3000
//    to_port     = 3000
//    protocol    = "TCP"
//    cidr_blocks = ["0.0.0.0/0"]
//  }
//
//  tags = merge(var.additional-tags, {})
//}