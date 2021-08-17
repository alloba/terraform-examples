variable "aws-region" {
  type = string
  description = "Region to run the infrastructure in"
}

variable "aws-profile" {
  type = string
  description = "local profile to use for aws access"
}

variable "efs-id" {
  type = string
  description = "The ID of the EFS instance created in the main terraform project."
}

variable "tags" {
  default = {
  }
}