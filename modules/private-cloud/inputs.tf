variable "vpc-cidr-range" {
  type = string
  default = "10.0.0.0/16"
  description = "The IP range of the target VPC. The provided range must encompass any ranges provided for subnets."
}

variable "availability-zones" {
  type = list(string)
  default = ["us-east-1a"]
  description = "List of availability zones for the target VPC. The number of zones must match the number of public/private subnets."
}

variable "public-subnet-cidrs" {
  type = list(string)
  default = ["10.0.1.0/24"]
  description = "IP ranges for subnets. The number of inputs here is used to control number of subnets created."
}

variable "private-subnet-cidrs" {
  type = list(string)
  default = ["10.0.2.0/24"]
  description = "IP ranges for subnets. The number of inputs here is used to control number of subnets created."
}

variable "enable-public-networking" {
  type = bool
  default = false
  description = "Turn on or off public network access. Meaning, EIP + IG + Routing Rules"
}

variable "additional-tags" {
  type = map(string)
  default = {}
  description = "Additional tags that should be applied to all resources in the module. (Project/Env/Owner/Etc.)"
}