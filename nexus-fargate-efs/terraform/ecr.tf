resource "aws_ecr_repository" "nexus-ecr-repo" {
  name = "nexus-container-repo"

  tags = merge(local.common_tags, {})
}
