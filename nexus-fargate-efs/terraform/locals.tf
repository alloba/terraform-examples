locals {
  common_tags = {
    environment = terraform.workspace,
    tf_repo     = "nexus-setup",
  }
}