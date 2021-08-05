resource "aws_cognito_user_pool" "cognito-module-user-pool" {
  name = "${var.name-prefix}-userpool"

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

  lambda_config {
    pre_sign_up = aws_lambda_function.auto-confirm-lambda.arn
    post_confirmation = aws_lambda_function.assign-group-lambda.arn
  }

  tags = {
    terraform: true
    project: "spring-cognito-integration"
  }
}

resource "aws_cognito_user_pool_client" "cognito-module-pool-client" {
  name         = "terraform-test-user-pool"
  user_pool_id = aws_cognito_user_pool.cognito-module-user-pool.id

  supported_identity_providers = ["COGNITO"]

  allowed_oauth_flows                  = ["implicit", "code"] # implicit == provide identity token directly (not recommended), code == authorization code, refreshable
  allowed_oauth_scopes                 = concat(["openid"], aws_cognito_resource_server.cognito-module-resource-server.scope_identifiers.*)
  allowed_oauth_flows_user_pool_client = true
  generate_secret                      = true

  callback_urls       = ["https://oauth.pstmn.io/v1/callback"]
  explicit_auth_flows = ["ALLOW_USER_PASSWORD_AUTH", "ALLOW_REFRESH_TOKEN_AUTH"]
}

resource "aws_cognito_user_pool_domain" "cognito-module-pool-domain" {
  domain       = var.user-pool-domain
  user_pool_id = aws_cognito_user_pool.cognito-module-user-pool.id
}

resource "aws_cognito_resource_server" "cognito-module-resource-server" {
  identifier = "testing-resource"
  name = "${var.name-prefix}-resource-server"
  user_pool_id = aws_cognito_user_pool.cognito-module-user-pool.id

  scope {
      scope_description = "read scope"
      scope_name = "READ"
  }

  scope {
      scope_description = "write scope"
      scope_name = "WRITE"
  }
}

# Placeholder. TODO: maybe inject the group into the lambda via environment params.
resource "aws_cognito_user_group" "cognito-module-usergroup-users" {
  name = "users"
  user_pool_id = aws_cognito_user_pool.cognito-module-user-pool.id
}

