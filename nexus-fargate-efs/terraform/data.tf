data "aws_vpc" "vpc-host" {
  tags = {
    environment: "infra-usw2"
    Name: "infra"
  }
}



data "aws_subnet" "public-west-c" {
  tags = {
    Name: "Infrastructure Public C"
    environment: "infra-usw2"
  }
}

data "aws_subnet" "public-west-a" {
  tags = {
    Name: "Infrastructure Public A"
    environment: "infra-usw2"
  }
}

data "aws_subnet" "public-west-b" {
  tags = {
    Name: "Infrastructure Public B"
    environment: "infra-usw2"
  }
}



data "aws_ecs_cluster" "ecs-cluster" {
  cluster_name = "fargate-dev-tools"
}

data "aws_route53_zone" "hosted-zone" {
  name = "dev.clearcaptions.com"
  private_zone = false
  tags = {
    environment: "dev"
  }
}

