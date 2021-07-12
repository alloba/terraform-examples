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
 Provider blocks give configuration settings for whatever providers are going to be in use.
 Here, we declared aws as a provider in the terraform block, so we describe settings for it in this block.

 To me it seems like this would map pretty directly to just machine-level configurations that you may have for
 integration targets. (AWS, GCP, DataDog, etc.)
**/
provider "aws" {
  profile = "personal"
  region  = "us-east-1"
}


///////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////

/**
 Resources are the actual pieces of infrastructure that are being defined.
 This is where the real heavy stuff goes down, in terms of specific configurations and pieces that you need.

 I suspect you'll just be living inside of reference documentation for all time when it comes to resources blocks.
**/
resource "aws_cognito_user_pool" "cognito_user_pool" {
  name = "terraform-test-userpool"

  password_policy {
    minimum_length                   = 6
    require_lowercase                = true
    require_uppercase                = false
    require_numbers                  = false
    require_symbols                  = false
    temporary_password_validity_days = 100
  }

  admin_create_user_config {
    allow_admin_create_user_only = false
  }

  schema {
    attribute_data_type = "String"
    name                = "email"
    required            = false
    string_attribute_constraints {
      min_length = "1"
      max_length = "1000"
    }
  }

  mfa_configuration = "OFF"

  tags = {
    category = "terraform"
  }
}

resource "aws_cognito_user_pool_client" "terraform_user_pool_client" {
  name         = "terraform-test-user-pool"
  user_pool_id = aws_cognito_user_pool.cognito_user_pool.id

  supported_identity_providers = ["COGNITO"]

  allowed_oauth_flows                  = ["implicit"]
  allowed_oauth_scopes                 = ["openid"]
  allowed_oauth_flows_user_pool_client = true
  generate_secret                      = true

  callback_urls       = ["https://oauth.pstmn.io/v1/callback"]
  explicit_auth_flows = ["ALLOW_USER_PASSWORD_AUTH", "ALLOW_REFRESH_TOKEN_AUTH"]
}

resource "aws_cognito_user_pool_domain" "terraform_user_pool_domain" {
  domain       = "terraform-test-domain-alloba-guf-unique"
  user_pool_id = aws_cognito_user_pool.cognito_user_pool.id
}

///////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////

resource "aws_lambda_function" "terraform_gateway_lambda_hello_world" {
  function_name    = "hello-lambda-world"
  handler          = "main.handler"
  role             = aws_iam_role.terraform_lambda_exec_role.arn
  runtime          = "nodejs12.x"
  filename         = "${path.module}/lambdas/main.zip"
  source_code_hash = data.archive_file.lambda_archive.output_base64sha256

  tags = {
    category = "terraform"
  }
}

resource "aws_iam_role" "terraform_lambda_exec_role" {
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}


resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.terraform_gateway_lambda_hello_world.function_name
  principal     = "apigateway.amazonaws.com"

  # The "/*/*" portion grants access from any method on any resource
  # within the API Gateway REST API.
  source_arn = "${aws_api_gateway_rest_api.terraform_gateway_test.execution_arn}/*/*"
}

data "archive_file" "lambda_archive" {
  type        = "zip"
  source_file = "${path.module}/lambdas/main.js"
  output_path = "${path.module}/lambdas/main.zip"
}

///////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////

resource "aws_api_gateway_rest_api" "terraform_gateway_test" {
  name = "terraform-gateway-test"
}

resource "aws_api_gateway_resource" "terraform_gateway_resource" {
  parent_id   = aws_api_gateway_rest_api.terraform_gateway_test.root_resource_id
  rest_api_id = aws_api_gateway_rest_api.terraform_gateway_test.id
  path_part   = "test"
}

resource "aws_api_gateway_method" "terraform_gateway_method" {
  authorization        = "COGNITO_USER_POOLS"
  authorization_scopes = aws_cognito_user_pool_client.terraform_user_pool_client.allowed_oauth_scopes #this can be narrowed down, but just allow anything from the auth setup to work here as a simple answer.
  authorizer_id        = aws_api_gateway_authorizer.terraform_gateway_authorizer.id
  http_method          = "ANY"
  resource_id          = aws_api_gateway_resource.terraform_gateway_resource.id
  rest_api_id          = aws_api_gateway_rest_api.terraform_gateway_test.id
}

resource "aws_api_gateway_authorizer" "terraform_gateway_authorizer" {
  name          = "terraform-gateway-authorizer"
  rest_api_id   = aws_api_gateway_rest_api.terraform_gateway_test.id
  type          = "COGNITO_USER_POOLS"
  provider_arns = [aws_cognito_user_pool.cognito_user_pool.arn]

}

resource "aws_api_gateway_integration" "terraform_gateway_integration" {
  http_method             = aws_api_gateway_method.terraform_gateway_method.http_method
  resource_id             = aws_api_gateway_resource.terraform_gateway_resource.id
  rest_api_id             = aws_api_gateway_rest_api.terraform_gateway_test.id
  type                    = "AWS_PROXY"
  integration_http_method = "POST"
  uri                     = aws_lambda_function.terraform_gateway_lambda_hello_world.invoke_arn
}

resource "aws_api_gateway_integration_response" "terraform_gateway_integration_response" {
  http_method = aws_api_gateway_method.terraform_gateway_method.http_method
  resource_id = aws_api_gateway_resource.terraform_gateway_resource.id
  rest_api_id = aws_api_gateway_rest_api.terraform_gateway_test.id
  status_code = "200"
  depends_on  = [aws_api_gateway_integration.terraform_gateway_integration] ## required to force a pause until creation complete
}

resource "aws_api_gateway_deployment" "terraform_gateway_deployment" {
  rest_api_id = aws_api_gateway_rest_api.terraform_gateway_test.id
  depends_on  = [aws_api_gateway_method.terraform_gateway_method, aws_api_gateway_integration.terraform_gateway_integration] ## this is required to force a pause on finalizing until the method is defined.
}

resource "aws_api_gateway_stage" "terraform_gateway_stage" {
  deployment_id = aws_api_gateway_deployment.terraform_gateway_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.terraform_gateway_test.id
  stage_name    = "test"
}

## TODO Getting unatuthorized when trying to hit endpoint. seems to not be a problem when i manually create an endpoint + lambda from the console.
## Update - it seem like its due to postman trying to use the bearer token as the authorization header, instead of using what
##          the gateway requires, which is the id_token. They are both provided in the token request, but you have to go
##          digging for the latter.
##          It's weird, because i swear i didnt have to do this earlier, with a different gateway.

# OKAY NEW UPDATE. Something in the act of allowing extra auth flows in the user pool client configuration fucks this up.
# ONLY enable 'ALLOW_USER_PASSWORD_AUTH' as an auth flow, and it will work just fine. I dont understand auth.

## Even newer update, im not sure any of the above is actually true. There are a couple of floating confusion points.
## possibly all of this was caused by not defining oath scopes on the api methods themselves.