terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.49"
    }
  }
  required_version = "1.0.0"

//  backend "s3" {
//      bucket = "clearcaptions-terraform"
//      key    = "nexus-setup.tfstate"
//      region = "us-west-2"
//    }
}

provider "aws" {
  region  = var.aws-region
  profile = var.aws-profile
}
