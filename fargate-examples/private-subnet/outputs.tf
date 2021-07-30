output "ecr_url" {
  value = aws_ecr_repository.terraform-example-fargate-ecr.repository_url
}

output "alb_url" {
  value = "http://${aws_alb.terraform-ex-fargate-aws-alb.dns_name}"
}