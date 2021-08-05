/**
 The terraform block contains core terraform settings.
 Specifically in this case, the provider definition.
**/
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws" # this basically a shorthand way of defining the registry source. (registry.terraform.io/hashicorp/aws)
      version = "~> 3.49"       # ~> means to allow only patch releases within a minor version (get most recent patch inside of 3.27)
    }
  }

  required_version = ">= 1.0.0" # minimum terraform version required.
}
