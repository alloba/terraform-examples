terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.49"
    }
  }

  required_version = "1.0.0"
}

resource "aws_vpc" "vpc" {
  cidr_block = var.vpc-cidr-range

  tags = merge(var.additional-tags, {})
}
