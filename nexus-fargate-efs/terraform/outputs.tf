
output "ecr-repo" {
  value = aws_ecr_repository.nexus-ecr-repo.repository_url
}

output "endpoint" {
  value = aws_route53_record.nexus-endpoint.fqdn
}

output "service-name" {
  value = aws_ecs_service.nexus-fargate-service.name
}

output "efs-id" {
  value = aws_efs_file_system.nexus-fs.id
}