variable "parent_cluster_name" {
  type = string
  default = "terraform-testing-parent-ecs-cluster-name"
}

variable "parent_lb_target_group" {
  type = string
  default = "terraform-testing-lb-target-group"
}

variable "image_full" {
  description = "This is the fully resolved name of the docker image to use for deployment. By default a simple hello world is used."
  type = string
  default = "tutum/hello-world"
}