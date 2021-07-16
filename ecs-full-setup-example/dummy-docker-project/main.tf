terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 3.49"
    }
  }

  backend "s3" {
    bucket = "alloba-terraform-state-files"
    key = "dummy-docker-project-ecs"
    region = "us-east-1"
  }

  required_version = ">= 1.0.0"
}
provider "aws" {
  region  = "us-east-1"
  profile = "personal"
}

locals {
  container_definition_name = "first"
}

resource "aws_ecr_repository" "testing_ecr_repo" {
  name = "testing-ecr-repo"
  image_tag_mutability = "MUTABLE"
}

resource "aws_ecs_task_definition" "test_ecs_task_definition" {
  family = "service"
  container_definitions = jsonencode([
    {
      name      = local.container_definition_name
      image     = var.image_full
      memoryReservation=200
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
    }
  ])
}

resource "aws_ecs_service" "test_ecs_service" {
  name = "test-ecs-service"
  cluster = data.aws_ssm_parameter.parent_ecs_cluster_name.value
  force_new_deployment = true # TODO: what does this do?
  desired_count = 1
  launch_type = "EC2"
  task_definition = aws_ecs_task_definition.test_ecs_task_definition.arn

  load_balancer {
    target_group_arn = data.aws_ssm_parameter.lb_target_group.value
    container_name = local.container_definition_name
    container_port = 80
  }
}

output "ecr_repo_worker_endpoint" {
  value = aws_ecr_repository.testing_ecr_repo.repository_url
}
