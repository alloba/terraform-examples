output "implicit_login_url" {
  value = join("", ["https://", aws_cognito_user_pool_domain.cognito-module-pool-domain.domain, ".auth.us-east-1.amazoncognito.com/login"])
}
output "authorize_url" {
  value = join("", ["https://", aws_cognito_user_pool_domain.cognito-module-pool-domain.domain, ".auth.us-east-1.amazoncognito.com/oauth2/authorize"])
}
output "access_token_url" {
  value = join("", ["https://", aws_cognito_user_pool_domain.cognito-module-pool-domain.domain, ".auth.us-east-1.amazoncognito.com/oauth2/token"])
}
output "callback_url" {
  value = aws_cognito_user_pool_client.cognito-module-pool-client.callback_urls
}
output "client_id" {
  value = aws_cognito_user_pool_client.cognito-module-pool-client.id
}
output "client_secret" {
  #sensitive = true
  # THIS IS OBVIOUSLY NOT PROD ACCEPTABLE. PURELY FOR LEARNING/TINKERING PURPOSES
  value = nonsensitive(aws_cognito_user_pool_client.cognito-module-pool-client.client_secret)
}
output "scope" {
  value = aws_cognito_user_pool_client.cognito-module-pool-client.allowed_oauth_scopes
}
output "pool_id" {
  value = aws_cognito_user_pool.cognito-module-user-pool.id
}


output "pool-client-allowed-oauth-scopes" {
  value = aws_cognito_user_pool_client.cognito-module-pool-client.allowed_oauth_scopes
}

output "pool-arn" {
  value = aws_cognito_user_pool.cognito-module-user-pool.arn
}