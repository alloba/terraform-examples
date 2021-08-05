output "gateway_endpoint" {
  value = aws_api_gateway_stage.terraform_gateway_stage.invoke_url
}

output "cognito-module" {
  value = module.cognito-pool-module
}