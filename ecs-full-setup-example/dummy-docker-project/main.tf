terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 3.49"
    }
  }

  required_version = ">= 1.0.0"
}
provider "aws" {
  region  = "us-east-1"
  profile = "personal"
}

resource "aws_ecr_repository" "testing_ecr_repo" {
  name = "testing-ecr-repo"
}

#TODO: this does not really tear down the running tasks on destroy. not sure how to address that. maybe its just a slow operation due to connection draining?
resource "aws_ecs_task_definition" "test_ecs_task_definition" {
  family = "service"
  container_definitions = jsonencode([
    {
      name      = "first"
      image     = "tutum/hello-world" # this is just a whatever docker image from the registry. this would be replaced by a custom image.
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


output "ecr_repo_worker_endpoint" {
  value = aws_ecr_repository.testing_ecr_repo.repository_url
}

data "aws_ecs_cluster" "imported_test_ecs_cluster" {
  cluster_name = "terraform-testing-ecs-cluster" ## FIXME: DIRECT REFERENCE TO EXTERNAL RESOURCE. this is obviously pretty stinky.
}

resource "aws_ecs_service" "test_ecs_service" {
  name = "test-ecs-service"
  cluster = data.aws_ecs_cluster.imported_test_ecs_cluster.id
  desired_count = 1
  launch_type = "EC2"
  task_definition = aws_ecs_task_definition.test_ecs_task_definition.arn
}

