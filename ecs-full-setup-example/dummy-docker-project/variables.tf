variable "parent_cluster_name" {
  type = string
  default = "terraform-testing-parent-ecs-cluster-name"
}

variable "parent_lb_target_group" {
  type = string
  default = "terraform-testing-lb-target-group"
}

variable "image_full" {
  type = string
  default = "tutum/hello-world"
}