resource "aws_ssm_parameter" "parent_ecs_cluster_name" {
  name  = "${var.environment-name}-parent-ecs-cluster-name"
  type  = "String"
  value = aws_ecs_cluster.testing_ecs_cluster.name
}

resource "aws_ssm_parameter" "lb_target_group" {
  name = "${var.environment-name}-lb-target-group"
  type = "String"
  value = aws_alb_target_group.lb_target_group.arn
}