resource "aws_route53_record" "ipv4" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = var.hostname
  type    = "A"

  alias {
    name                   = module.alb.lb_dns_name
    zone_id                = module.alb.lb_zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "ipv6" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = var.hostname
  type    = "AAAA"

  alias {
    name                   = module.alb.lb_dns_name
    zone_id                = module.alb.lb_zone_id
    evaluate_target_health = true
  }
}

module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 6.0"

  name_prefix = "rtmp-"

  load_balancer_type = "network"

  vpc_id                      = data.aws_vpc.current.id
  subnets                     = data.aws_subnet_ids.public.ids
  ip_address_type             = "dualstack"
  listener_ssl_policy_default = "ELBSecurityPolicy-FS-1-2-Res-2020-10"

  target_groups = [
    {
      name_prefix       = "rtmp-"
      backend_port      = 1935
      backend_protocol  = "TCP"
      target_type       = "ip"
      proxy_protocol_v2 = false
    },
    {
      name_prefix       = "nginx-"
      backend_port      = 8080
      backend_protocol  = "TCP"
      target_type       = "ip"
      healthcheck = {
        path     = "/stat"
        protocol = "HTTP"
      }
    }
  ]

  https_listeners = [
    {
      port            = 443
      protocol        = "TLS"
      certificate_arn = data.aws_acm_certificate.issued.arn
    },
    {
      port            = 8443
      protocol        = "TLS"
      alpn_policy     = "HTTP2Preferred"
      certificate_arn = data.aws_acm_certificate.issued.arn
    }
  ]

  tags = {
    App       = "nginx-rtmp"
    Terraform = "true"
  }
}