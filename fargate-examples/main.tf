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
    key    = "fargate-example"
    region = "us-east-1"
  }
}

provider "aws" {
  region  = "us-east-1"
  profile = "personal"
}

module "vpc-infra" {
  source = "../modules/vpc-privatesubnets-nats"

  vpc-cidr-range           = "10.0.0.0/16"
  availability-zones       = ["us-east-1a"]
  public-subnet-cidrs      = ["10.0.1.0/24"]
  private-subnet-cidrs     = ["10.0.3.0/24"]
  enable-public-networking = true
  additional-tags = {
    Name : "fargate-testing"
    Owner : "Alex Bates"
  Environment : "Testing" }
}