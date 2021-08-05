variable "name-prefix" {
  type = string
  default = "cognito-module"
}

variable "user-pool-domain" {
  type = string
  default = "guffy-cognito-module"
}

variable "default-usergroup" {
  type = string
  default = "users"
}