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
