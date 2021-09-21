data "aws_region" "current" {}

module "rtmp_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name            = "rtmp"
  use_name_prefix = true
  vpc_id          = data.terraform_remote_state.vpc.outputs.vpc_id
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