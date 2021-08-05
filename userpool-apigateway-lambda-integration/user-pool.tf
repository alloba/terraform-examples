module "cognito-pool-module" {
  source = "../modules/cognito-userpool"

  default-usergroup = "users"
  name-prefix = "gateway-example-guffy"
  user-pool-domain = "gateway-example-guffy"
}
