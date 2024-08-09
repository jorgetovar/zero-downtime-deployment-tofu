provider "aws" {
  region = "us-east-2"
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "subnets" {
  filter {
    name = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
  tags = {
    Tier = "Public"
  }
}

module "zdd_application" {
  source       = "../../modules/web-cluster"
  ami          = var.ami
  cluster_name = "aws-builders-zdd"
  vpc_id       = data.aws_vpc.default.id
  subnets      = data.aws_subnets.subnets.ids
}