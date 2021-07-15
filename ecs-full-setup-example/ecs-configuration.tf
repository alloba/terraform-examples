data "aws_iam_policy_document" "testing_iam_policy_ecs" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      identifiers = ["ec2.amazonaws.com"]
      type        = "Service"
    }
  }
}

resource "aws_iam_role" "testing_iam_role" {
  assume_role_policy = data.aws_iam_policy_document.testing_iam_policy_ecs.json
  name               = "${var.environment-name}-ecs-agent"
}

resource "aws_iam_policy_attachment" "testing_iam_policy_attachment" {
  name       = "${var.environment-name}-ecs-agent-policy-attachment"
  roles      = [aws_iam_role.testing_iam_role.id]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role" # this maps to a policy that would show up in the list that you can add to iam roles.
}

resource "aws_iam_instance_profile" "testing_iam_instance_profile" {
  name = "${var.environment-name}-ecs-agent"
  role = aws_iam_role.testing_iam_role.name
}


# TODO: i probably definitely dont want this in the long run. This was being used as a mechanism to troubleshoot (although i do want some way to ssh into containers in the end)
resource "tls_private_key" "testing_tls_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "testing_ssh_key" {
  public_key = tls_private_key.testing_tls_key.public_key_openssh
  key_name   = "${var.environment-name}-name"
  provisioner "local-exec" {
    command = "echo '${tls_private_key.testing_tls_key.private_key_pem}' > ./myKey.pem"
  }
}


# the autoscaling group seems a bit sensitive to edits on a live stack, since it gets utilized by the autoscaling group (and doesnt want to detach)
resource "aws_launch_configuration" "testing_ecs_launch_config" {
  image_id             = "ami-091aa67fccd794d5f" # ecs optimized ami
  instance_type        = "t2.micro"
  iam_instance_profile = aws_iam_instance_profile.testing_iam_instance_profile.name
  security_groups      = [aws_security_group.load_balancer_security_group.id]
  user_data            = "#!/bin/bash\necho ECS_CLUSTER=${aws_ecs_cluster.testing_ecs_cluster.name} >> /etc/ecs/ecs.config" # the ECS_CLUSTER variable is a direct reference to the cluster name defined in a separate resource.

  key_name                    = aws_key_pair.testing_ssh_key.key_name
  associate_public_ip_address = true #TODO: this is required for the cluster and the ec2 instance to connect. this supposedly can be replaced with a private nat gateway, but i dont know how to do that yet.

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "testing_autoscaling_group" {
  max_size             = 2
  min_size             = 1
  name                 = "${var.environment-name}-autoscaling-group"
  vpc_zone_identifier  = aws_subnet.public_subnets[*].id
  launch_configuration = aws_launch_configuration.testing_ecs_launch_config.name
}

resource "aws_ecs_cluster" "testing_ecs_cluster" {
  # Note: It's nothing in the cluster definition that actually attached EC2 instances to the cluster.
  # That comes fully from the EC2 instance itself, via a docker agent that is running by default.
  # This is also one of the reasons why it is important to use ami's that are configured for ecs (so the registration service will be running on startup)
  name = "${var.environment-name}-ecs-cluster"
}