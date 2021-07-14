# A lot of the initial setup for this came from the following post online:
# https://medium.com/warp9/get-started-with-aws-ecs-cluster-using-terraform-cfba531f7748

terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      # this basically a shorthand way of defining the registry source. (registry.terraform.io/hashicorp/aws)
      version = "~> 3.49"
      # ~> means to allow only patch releases within a minor version (get most recent patch inside of 3.27)
    }
  }

  required_version = ">= 1.0.0" # minimum terraform version required.

  //  terraform state can be pushed to different backends. by default it is stored locally.
  //  this pushes it to an s3 bucket in aws.
  //  the assumption being that you have valid rights to create/push/read files in the bucket.

  //  i dont feel like creating a bucket though, and also this stuff is zero percent critical, so im commenting this out.
  //  backend "s3" {
  //    bucket = "alloba-terraformstate-ecsfullexample"
  //    key = "terraform.tfstate"
  //    region = "us-east-1"
  //    profile = "personal"
  //  }
}

provider "aws" {
  region  = "us-east-1"
  profile = "personal"
}