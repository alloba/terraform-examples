variable "environment-name" {
  type    = string
  default = "terraform-testing"
}

variable "vpc-cidr" {
  type    = string
  default = "10.0.0.0/22" # 10.0.0.0 -> 10.0.0.3.355
}

variable "public-subnets" {
  type    = list(string)
  default = ["10.0.0.0/25", "10.0.1.0/25"] # 10.0.0.0 -> 10.0.0.127, 10.0.1.0 -> 10.0.1.127
}

variable "private-subnets" {
  type    = list(string)
  default = ["10.0.2.0/25", "10.0.3.0/25"] # 10.0.2.0 -> 10.0.2.127, 10.0.3.0 -> 10.0.3.127
}