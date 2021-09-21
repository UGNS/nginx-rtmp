data "aws_region" "current" {}

data "aws_vpc" "current" {
    name = var.vpc_name
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
      from_port   = var.rtmp_port
      to_port     = var.rtmp_port
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
  ingress_with_ipv6_cidr_blocks = [
    {
      from_port        = var.rtmp_port
      to_port          = var.rtmp_port
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