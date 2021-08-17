terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.49"
    }
  }
  required_version = "1.0.0"
}

provider "aws" {
  region  = var.aws-region
  profile = var.aws-profile
}



resource "aws_instance" "test-ec2-instance" {
  ami = "ami-a0cfeed8"
  instance_type = "t2.micro"
  key_name = "ssh-key-val"
  security_groups = [aws_security_group.ec2-sg.id]
  user_data = data.template_file.script.rendered

  subnet_id = data.aws_subnet.public-west-a.id
  associate_public_ip_address = true
  tags = {Name: "nexus-shell-deleteme"}
}

data "template_file" "script" {
  template = file("script.tpl")
  vars = {
    efs_id = var.efs-id
  }
}
