data "aws_ssm_parameter" "parent_ecs_cluster_name" {
  name = var.parent_cluster_name
}