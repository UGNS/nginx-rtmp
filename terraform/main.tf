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
    App       = "nginx-rtmp"
    ManagedBy = "Terraform"
  }

}