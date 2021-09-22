data "aws_region" "current" {}

data "aws_vpc" "current" {
  tags = {
    Name = var.vpc_name
  }
}

data "aws_subnet_ids" "private" {
  vpc_id = data.aws_vpc.current.id

  tags = {
    Reach = "private"
  }
}

data "aws_subnet_ids" "public" {
  vpc_id = data.aws_vpc.current.id

  tags = {
    Reach = "public"
  }
}

data "aws_ecr_repository" "rtmp" {
  name = "ugns/nginx-rtmp"
}

data "aws_acm_certificate" "issued" {
  domain      = var.domain
  statuses    = ["ISSUED"]
  most_recent = true
}

data "aws_route53_zone" "selected" {
  name         = var.domain
  private_zone = false
}

module "rtmp_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name            = "rtmp"
  use_name_prefix = true
  vpc_id          = data.aws_vpc.current.id
  description     = "Security group for usage with NLB"

  ingress_with_cidr_blocks = [
    {
      from_port   = 1935
      to_port     = 1935
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
  ingress_with_ipv6_cidr_blocks = [
    {
      from_port        = 1935
      to_port          = 1935
      protocol         = "tcp"
      ipv6_cidr_blocks = "::/0"
    }
  ]
  egress_rules = ["all-all"]

  tags = {
    App       = "nginx-rtmp"
    ManagedBy = "Terraform"
  }
}