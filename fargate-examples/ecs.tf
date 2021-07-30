resource "aws_ecr_repository" "terraform-example-fargate-ecr" {
  name = "terraform-example-fargate-ecr"
}

resource "aws_ecs_cluster" "terraform-example-fargate-cluster" {
  name = "terraform-example-fargate-cluster"
}

resource "aws_ecs_task_definition" "terraform-example-task-definition" {
  family             = "terraform-example-fargate"
  execution_role_arn = aws_iam_role.terraform-example-fargate-iam.arn

  container_definitions = jsonencode(
    [
      {
        name  = "terraform-example-fargate-container",
        image = aws_ecr_repository.terraform-example-fargate-ecr.repository_url,
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
  name            = "terraform-example-fargate"
  cluster         = aws_ecs_cluster.terraform-example-fargate-cluster.id
  task_definition = aws_ecs_task_definition.terraform-example-task-definition.arn
  launch_type     = "FARGATE"
  desired_count   = 1

  network_configuration {
    assign_public_ip = false
    security_groups = [
      module.vpc-infra.security_group_egress_all_id,
      module.vpc-infra.security_group_ingress_http_id
    ]
    subnets = module.vpc-infra.private_subnet_ids
  }

  load_balancer {
    container_name   = "terraform-example-fargate-container" # defined in aws_ecs_task_definition
    container_port   = 80                                    # defined in defined in aws_ecs_task_definition
    target_group_arn = aws_lb_target_group.terraform-example-fargate-lb-target.arn
  }
}

resource "aws_iam_role" "terraform-example-fargate-iam" {
  name               = "terraform-example-fargate-iam"
  assume_role_policy = data.aws_iam_policy_document.terraform-example-fargate-iam-policy.json
}

data "aws_iam_policy_document" "terraform-example-fargate-iam-policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      identifiers = ["ecs-tasks.amazonaws.com"]
      type        = "Service"
    }
  }
}

data "aws_iam_policy" "terraform-example-fargate-iam-role" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "terraform-example-fargate-role-attachment" {
  policy_arn = data.aws_iam_policy.terraform-example-fargate-iam-role.arn
  role       = aws_iam_role.terraform-example-fargate-iam.name
}

resource "aws_lb_target_group" "terraform-example-fargate-lb-target" {
  name        = "fargate-test-http"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = module.vpc-infra.vpc_id

  health_check {
    enabled = true
    path    = "/"
  }

  depends_on = [aws_alb.terraform-ex-fargate-aws-alb]
}

resource "aws_alb" "terraform-ex-fargate-aws-alb" {
  name               = "terraform-ex-fargate-aws-alb"
  internal           = false
  load_balancer_type = "application"

  subnets = concat(module.vpc-infra.private_subnet_ids, module.vpc-infra.public_subnet_ids)

  security_groups = [
    module.vpc-infra.security_group_egress_all_id,
    module.vpc-infra.security_group_ingress_http_id
  ]

  depends_on = [module.vpc-infra.internet_gateway_id] # not sure if this will really work the right way. I think the expectation is that you provide a resource directly for this.
}

resource "aws_alb_listener" "terraform-example-fargate-alb-listener" {
  load_balancer_arn = aws_alb.terraform-ex-fargate-aws-alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.terraform-example-fargate-lb-target.arn
  }
}
