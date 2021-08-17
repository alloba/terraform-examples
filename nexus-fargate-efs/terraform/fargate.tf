resource "aws_ecs_task_definition" "nexus-task-definition" {
  family             = "nexus"
  execution_role_arn = aws_iam_role.nexus-iam-role.arn

  container_definitions = jsonencode(
  [
    {
      name  = "nexus-container",
      image = "${aws_ecr_repository.nexus-ecr-repo.repository_url}:${var.nexus-image-version}",
      portMappings = [
        {
          containerPort : 8081
          hostPort: 8081
        }
      ]

      mountPoints: [
        {
          containerPath: "/nexus-data" # where the volume will be mounted in the container (should end up being /nexus-data )
          sourceVolume: "nexus-volume" # named in volume definition below
          readOnly: false
        }
      ]

      ulimits: [
        {
          softLimit: 2048,
          hardLimit: 65536,
          name: "nofile"
        }
      ]

      logConfiguration: {
        logDriver: "awslogs",
        options: {
          awslogs-group: "/fargate/service/${terraform.workspace}-nexus",
          awslogs-region: var.aws-region,
          awslogs-stream-prefix: "fargate",
        }
      }
    }
  ]
  )

  cpu                      = "1024"
  memory                   = "8192"
  requires_compatibilities = ["FARGATE"]

  network_mode = "awsvpc"

  volume {
    name = "nexus-volume"

    efs_volume_configuration {
      file_system_id = aws_efs_file_system.nexus-fs.id
      root_directory = "/mnt/efs"
      transit_encryption = "ENABLED"
      transit_encryption_port = 2999
      authorization_config {
        access_point_id = aws_efs_access_point.nexus-fs-accesspoint.id
        iam = "DISABLED"
      }
    }
  }

  tags = merge(local.common_tags, {forceUpdate: "1"})
}



resource "aws_ecs_service" "nexus-fargate-service" {
  name = "nexus-service"
  cluster = data.aws_ecs_cluster.ecs-cluster.id
  task_definition = aws_ecs_task_definition.nexus-task-definition.arn
  launch_type = "FARGATE"
  platform_version = "1.4.0"
  desired_count = 1
  deployment_maximum_percent = 100
  deployment_minimum_healthy_percent = 0


  network_configuration {
    assign_public_ip = true
    security_groups = [
      aws_security_group.ecs-sg.id
    ]
    subnets = [
      data.aws_subnet.public-west-a.id,
      data.aws_subnet.public-west-b.id,
      data.aws_subnet.public-west-c.id,
    ]
  }

  load_balancer {
    container_name   = "nexus-container" # defined in aws_ecs_task_definition (name field)
    container_port   = 8081              # in aws_ecs_task_definition (port mappings)
    target_group_arn = aws_lb_target_group.nexus-lb-targetgroup.arn
  }

  depends_on = [aws_alb.nexus-lb]

  tags = merge(local.common_tags, {})
}

resource "aws_cloudwatch_log_group" "logs" {
  name              = "/fargate/service/${terraform.workspace}-nexus"
  retention_in_days = 7
  tags = merge(local.common_tags, {})
}