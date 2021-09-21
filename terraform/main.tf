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
    Terraform = "true"
  }

}

resource "aws_lb_target_group" "nginx-rtmp" {
  name_prefix = "rtmp-"
  port        = 1935
  protocol    = "TCP"
  target_type = "ip"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id

  health_check {
    protocol = "TCP"
  }
  tags = {
    Name      = "nginx-rtmp"
    Terraform = "true"
  }
}