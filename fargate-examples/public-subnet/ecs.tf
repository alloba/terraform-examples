resource "aws_ecs_cluster" "terraform-example-fargate-cluster" {
  name = "terraform-example-fargate-cluster"
}

resource "aws_ecr_repository" "terraform-example-fargate-ecr" {
  name = "terraform-example-fargate-public-ecr"
}


resource "aws_ecs_task_definition" "terraform-example-task-definition" {
  family             = "terraform-example-fargate"
  execution_role_arn = aws_iam_role.terraform-example-fargate-iam.arn

  container_definitions = jsonencode(
  [
    {
      name  = "terraform-example-fargate-container",
      image = "${aws_ecr_repository.terraform-example-fargate-ecr.repository_url}:${var.task-version-number}",
      portMappings = [
        {
          containerPort : 80,
        }
      ]
    }
  ]
  )

  cpu                      = "256"
  memory                   = "512"
  requires_compatibilities = ["FARGATE"]

  network_mode = "awsvpc"
}

resource "aws_ecs_service" "terraform-example-fargate" {
  name = "terraform-example-fargate"
  cluster = aws_ecs_cluster.terraform-example-fargate-cluster.id
  task_definition = aws_ecs_task_definition.terraform-example-task-definition.arn
  launch_type = "FARGATE"
  desired_count = 1

  network_configuration {
    assign_public_ip = true
    security_groups = [
      aws_security_group.egress-all.id,
      aws_security_group.https.id,
      aws_security_group.http.id
    ]
    subnets = aws_subnet.public-subnets[*].id
  }

  load_balancer {
    container_name   = "terraform-example-fargate-container" # defined in aws_ecs_task_definition
    container_port   = 80                                    # defined in defined in aws_ecs_task_definition
    target_group_arn = aws_lb_target_group.terraform-example-fargate-lb-target.arn
  }
}

