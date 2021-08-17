variable "nexus-image-version" {
  type = string
  description = "The target version of the nexus docker container that should be ran in the cluster."
  default = "LATEST"
}

variable "aws-region" {
  type = string
  description = "Region to run the infrastructure in"
}

variable "aws-profile" {
  type = string
  description = "local profile to use for aws access"
}
