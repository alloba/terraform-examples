data "aws_iam_policy_document" "nexus-iam-policy-doc" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      identifiers = ["ecs-tasks.amazonaws.com"]
      type        = "Service"
    }
  }
}

data "aws_iam_policy" "nexus-iam-policy" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "nexus-policy-attachment" {
  policy_arn = data.aws_iam_policy.nexus-iam-policy.arn
  role       = aws_iam_role.nexus-iam-role.name
}

resource "aws_iam_role" "nexus-iam-role" {
  name               = "nexus-assumerole-ecs"
  assume_role_policy = data.aws_iam_policy_document.nexus-iam-policy-doc.json
}