terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.49"
    }
  }

  required_version = "1.0.0"

  backend "s3" {
    bucket = "alloba-terraform-state-files"
    key    = "fargate-public-subnet-example"
    region = "us-east-1"
  }
}

provider "aws" {
  region  = "us-east-1"
  profile = "personal"
}
