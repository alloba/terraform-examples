/**
 Outputs that are useful going forward after creation. These can be seen in the console output for terraform operations
 on this stack, and can be referenced by other modules directly if needed. (somehow).
**/
output "gateway_endpoint" {
  value = aws_api_gateway_stage.terraform_gateway_stage.invoke_url
}
output "auth_url" {
  value = join("", ["https://", aws_cognito_user_pool_domain.terraform_user_pool_domain.domain, ".auth.us-east-1.amazoncognito.com/login"])
}
output "callback_url" {
  value = aws_cognito_user_pool_client.terraform_user_pool_client.callback_urls
}
output "client_id" {
  value = aws_cognito_user_pool_client.terraform_user_pool_client.id
}
output "scope" {
  value = aws_cognito_user_pool_client.terraform_user_pool_client.allowed_oauth_scopes
}

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

/**
 Provider blocks give configuration settings for whatever providers are going to be in use.
 Here, we declared aws as a provider in the terraform block, so we describe settings for it in this block.

 To me it seems like this would map pretty directly to just machine-level configurations that you may have for
 integration targets. (AWS, GCP, DataDog, etc.)
**/
provider "aws" {
  profile = "personal"
  region  = "us-east-1"
}