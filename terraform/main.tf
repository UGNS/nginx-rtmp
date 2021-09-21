data "aws_acm_certificate" "issued" {
  domain = var.domain
  status = ["ISSUED"]
}

module "rtmp_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 3.17"

  name            = "rtmp-sg"
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
  egress_rules = ["all-all"]

  tags = {
    Name      = "nginx-rtmp"
    ManagedBy = "Terraform"
  }

}

module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 6.0"

  name_prefix = "rtmp-"

  load_balancer_type = "network"

  vpc_id  = data.terraform_remote_state.vpc.outputs.vpc_id
  subnets = data.terraform_remote_state.vpc.outputs.public_subnets

  target_groups = [
    {
      name_prefix      = "rtmp-"
      backend_port     = 1935
      backend_protocol = "TCP"
      target_type      = "ip"

    }
  ]

  https_listeners = [
    {
      port               = 1936
      protocol           = "TLS"
      certificate_arn    = data.aws_acm_certificate.issued.arn
      target_group_index = 0
    }
  ]

  tags = {
    Name      = "nginx-rtmp"
    Terraform = "true"
  }
}