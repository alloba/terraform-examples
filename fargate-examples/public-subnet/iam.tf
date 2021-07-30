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

resource "aws_iam_role" "terraform-example-fargate-iam" {
  name               = "terraform-example-fargate-iam"
  assume_role_policy = data.aws_iam_policy_document.terraform-example-fargate-iam-policy.json
}