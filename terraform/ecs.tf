data "aws_ecr_image" "rtmp" {
  name      = "ugns/nginx-rtmp"
  image_tag = "latest"
}

module "ecs" {
  source  = "terraform-aws-modules/ecs/aws"
  version = "~> 3.0"

  name = "rtmp"

  container_insights = true

  capacity_providers = ["FARGATE", "FARGATE_SPOT"]

  default_capacity_provider_strategy = [
    {
      capacity_provider = "FARGATE_SPOT"
    }
  ]

  tags = {
    App       = "nginx-rtmp"
    ManagedBy = "Terraform"
  }
}

module "container_definition" {
  source  = "cloudposse/ecs-container-definitions/aws"
  version = "~> 0.58"

  container_name  = "rtmp"
  container_image = data.aws_ecr_image.rtmp.id

  map_environment = {
    "RTMP_PORT"        = var.rtmp_port
    "TWITCH_HOST"      = var.ttv_hostname
    "TWITCH_STREAMKEY" = var.ttv_streamkey
  }

  port_mappings = [
    {
      containerPort = var.rtmp_port
      protocol      = "tcp"
    }
  ]

  log_configuration = {
    logDriver = "awslogs"
    options = {
      "awslogs-group"         = "/ecs/nginx-rtmp"
      "awslogs-region"        = data.aws_region.current.name
      "awslogs-stream-prefix" = "ecs"
    }
  }
}

module "service_task" {
  source = "cloudposse/ecs-alb-service-task/aws"

  family                         = "nginx-rtmp"
  container_definition_json      = module.container_definition.json_map_encoded_list
  ecs_cluster_arn                = module.ecs.ecs_cluster_arn
  security_groups                = [module.rtmp_sg.security_group_id]
  network_mode                   = "awsvpc"
  desired_count                  = 1
  task_memory                    = var.task_memory
  task_cpu                       = var.task_cpu
  ignore_changes_task_definition = true
  ignore_changes_desired_count   = true

  capacity_provider_strategies = [
    {
      capacity_provider = "FARGATE_SPOT"
      weight            = 1
    }
  ]

  ecs_load_balancers = [
    {
      container_name   = "rtmp"
      container_port   = var.rtmp_port
      elb_name         = module.alb.lb_id
      target_group_arn = module.alb.target_group_arns[0]
    }
  ]
}
