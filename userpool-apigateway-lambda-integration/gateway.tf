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
  authorization_scopes = module.cognito-pool-module.pool-client-allowed-oauth-scopes #this can be narrowed down, but just allow anything from the auth setup to work here as a simple answer.
  authorizer_id        = aws_api_gateway_authorizer.terraform_gateway_authorizer.id
  http_method          = "ANY" ##this can be changed to whatever. GET probably.
  resource_id          = aws_api_gateway_resource.terraform_gateway_resource.id
  rest_api_id          = aws_api_gateway_rest_api.terraform_gateway_test.id
}

resource "aws_api_gateway_authorizer" "terraform_gateway_authorizer" {
  name          = "terraform-gateway-authorizer"
  rest_api_id   = aws_api_gateway_rest_api.terraform_gateway_test.id
  type          = "COGNITO_USER_POOLS"
  provider_arns = [module.cognito-pool-module.pool-arn]

}

resource "aws_api_gateway_integration" "terraform_gateway_integration" {
  http_method             = aws_api_gateway_method.terraform_gateway_method.http_method
  resource_id             = aws_api_gateway_resource.terraform_gateway_resource.id
  rest_api_id             = aws_api_gateway_rest_api.terraform_gateway_test.id
  type                    = "AWS_PROXY"
  integration_http_method = "POST" ## this is not the method type, this is specifically referring to integration. meaning, don't change it to fit some http call.
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