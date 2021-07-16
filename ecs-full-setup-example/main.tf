# A lot of the initial setup for this came from the following post online:
# https://medium.com/warp9/get-started-with-aws-ecs-cluster-using-terraform-cfba531f7748

terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 3.49"
    }
  }

  required_version = ">= 1.0.0" # minimum terraform version required.

  backend "s3" {
    bucket = "alloba-terraform-state-files"
    key = "ecs-full-example-project.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region  = "us-east-1"
  profile = "personal"
}