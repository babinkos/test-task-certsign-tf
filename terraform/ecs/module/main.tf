# based on https://github.com/terraform-aws-modules/terraform-aws-ecs/blob/master/examples/ec2-autoscaling/main.tf
provider "aws" {
  region = local.region
}

data "aws_availability_zones" "available" {}

locals {
  region = var.region
  name   = "certsign-${local.region}"

  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)

  container_name = "signsrv" # "${name}-${container_name}"  cannot be longer than 32 characters
  container_port = 80

  tags = {
    Name       = local.name
    Region     = local.region
    Example    = local.name
    Repository = "https://github.com/terraform-aws-modules/terraform-aws-ecs"
  }
}

################################################################################
# Cluster
################################################################################

module "ecs_cluster" {
  source = "terraform-aws-modules/ecs/aws//modules/cluster"

  cluster_name = local.name

  # Capacity provider - autoscaling groups
  default_capacity_provider_use_fargate = false
  autoscaling_capacity_providers = {
    # On-demand instances
    test-task = {
      auto_scaling_group_arn         = module.autoscaling["test-task"].autoscaling_group_arn
      managed_termination_protection = "ENABLED"

      managed_scaling = {
        maximum_scaling_step_size = 2
        minimum_scaling_step_size = 1
        status                    = "ENABLED"
        target_capacity           = var.ecs_asg_target_capacity
      }

      default_capacity_provider_strategy = {
        weight = 60
        base   = 20
      }
    }
  }

  tags = local.tags
}

################################################################################
# Service
################################################################################

module "ecs_service" {
  source = "terraform-aws-modules/ecs/aws//modules/service"

  # Service
  name        = local.name
  cluster_arn = module.ecs_cluster.arn

  launch_type = "EC2"

  desired_count = var.ecs_service_desired_count # Number of instances of the task definition to place and keep running

  autoscaling_min_capacity = var.ecs_service_min_capacity
  autoscaling_max_capacity = var.ecs_service_max_capacity # Maximum number of tasks to run in your service

  # Task size | t2.micro 1vCPU 1GB vRAM
  cpu    = var.ecs_service_task_cpu    # 1 vCPU = 1024
  memory = var.ecs_service_task_memory # if unset defaults to 2GB wich is more that 1GB for t2.micro

  # Task Definition
  requires_compatibilities = ["EC2"]
  runtime_platform         = var.runtime_platform
  capacity_provider_strategy = {
    # On-demand instances
    test-task = {
      capacity_provider = module.ecs_cluster.autoscaling_capacity_providers["test-task"].name
      weight            = 1
      base              = 1
    }
  }

  volume = {
    # my-vol = {}
  }

  # Container definition(s)
  container_definitions = {
    (local.container_name) = {
      # need this to define container size as part of Task
      # cpu    = var.container_definition_cpu
      memory = var.container_definition_memory

      memory_reservation = var.container_definition_memory_reservation

      essential = true # need at least one in Task
      # enable_cloudwatch_logging = false

      image = var.container_definition_image
      port_mappings = [
        {
          name          = local.container_name
          containerPort = local.container_port
          protocol      = "tcp"
        }
      ]

      command = ["/usr/local/bin/python", "sign_srv_fastapi.py"]
      environment = [
        { name : "CERT_VALIDITY_DAYS",
        value : var.cert_validity_days_cap }
      ]
      health_check = {
        "retries" : 3,
        "command" : [
          "CMD-SHELL",
          "/usr/bin/curl -sf http://localhost:80/healthz"
        ],
        "timeout" : 5,
        "interval" : 10,
        "startPeriod" : 80 # need at least 1min to start unicorn in container
      }
      # Example image used requires access to write to root filesystem
      # readonly_root_filesystem = false
      readonly_root_filesystem = true
    }
  }

  load_balancer = {
    service = {
      target_group_arn = element(module.alb.target_group_arns, 0)
      container_name   = local.container_name
      container_port   = local.container_port
    }
  }

  subnet_ids = module.vpc.private_subnets
  security_group_rules = {
    alb_http_ingress = {
      type                     = "ingress"
      from_port                = local.container_port
      to_port                  = local.container_port
      protocol                 = "tcp"
      description              = "Service port"
      source_security_group_id = module.alb_sg.security_group_id
    }
  }

  tags = local.tags
}

################################################################################
# Supporting Resources
################################################################################

# https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-optimized_AMI.html#ecs-optimized-ami-linux
data "aws_ssm_parameter" "ecs_optimized_ami" {
  name = var.ecs_optimized_ami_filter # https://docs.aws.amazon.com/AmazonECS/latest/developerguide/retrieve-ecs-optimized_AMI.html
}

module "alb_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = "${local.name}-service"
  description = "Service security group"
  vpc_id      = module.vpc.vpc_id

  ingress_rules = [
    "http-80-tcp",
    "https-443-tcp"
  ]
  ingress_cidr_blocks = ["0.0.0.0/0"]

  egress_rules       = ["all-all"]
  egress_cidr_blocks = module.vpc.private_subnets_cidr_blocks

  tags = local.tags
}

module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 8.0"

  name = local.name

  load_balancer_type = "application"

  vpc_id          = module.vpc.vpc_id
  subnets         = module.vpc.public_subnets
  security_groups = [module.alb_sg.security_group_id]

  http_tcp_listeners = [
    {
      port               = local.container_port
      protocol           = "HTTP"
      target_group_index = 0
    },
  ]
  http_tcp_listener_rules = [
    {
      http_tcp_listener_index = 0
      priority                = 1
      actions = [{
        type        = "redirect"
        status_code = "HTTP_301"
        protocol    = "HTTPS"
      }]
      conditions = [{
        path_patterns = ["/cert/*"]
      }]
    },
  ]
  https_listeners = [
    {
      port               = 443
      protocol           = "HTTPS"
      certificate_arn    = var.acm_certificate_arn
      target_group_index = 0
    },
  ]
  target_groups = [
    {
      name                          = "${local.name}-${local.container_name}"
      backend_protocol              = "HTTP"
      backend_port                  = local.container_port
      target_type                   = "ip"
      deregistration_delay          = var.alb_deregistration_delay
      load_balancing_algorithm_type = var.alb_load_balancing_algorithm_type
      health_check = {
        enabled             = var.alb_health_check_enabled
        interval            = var.alb_health_check_interval
        path                = "/healthz/alb"
        port                = "traffic-port"
        healthy_threshold   = var.alb_health_check_healthy_threshold
        unhealthy_threshold = var.alb_health_check_unhealthy_threshold
        timeout             = var.alb_health_check_timeout
        protocol            = "HTTP"
        matcher             = "200-399"
      }
    },
  ]

  tags = local.tags
}

module "autoscaling" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "~> 6.5"

  for_each = {
    # On-demand instances
    test-task = {
      instance_type              = var.autoscaling_instance_type # t4g.small
      use_mixed_instances_policy = false
      mixed_instances_policy     = {}
      user_data                  = <<-EOT
        #!/bin/bash
        cat <<'EOF' >> /etc/ecs/ecs.config
        ECS_CLUSTER=${local.name}
        ECS_LOGLEVEL=debug
        ECS_CONTAINER_INSTANCE_TAGS=${jsonencode(local.tags)}
        ECS_ENABLE_TASK_IAM_ROLE=true
        EOF
        sudo docker pull ${var.container_definition_image}
        sudo docker pull amazon/amazon-ecs-agent:latest
        sudo docker pull amazon/amazon-ecs-pause:latest
      EOT
    }
  }

  name = "${local.name}-${each.key}"

  image_id      = jsondecode(data.aws_ssm_parameter.ecs_optimized_ami.value)["image_id"]
  instance_type = each.value.instance_type

  security_groups                 = [module.autoscaling_sg.security_group_id]
  user_data                       = base64encode(each.value.user_data)
  ignore_desired_capacity_changes = true

  create_iam_instance_profile = true
  iam_role_name               = local.name
  iam_role_description        = "ECS role for ${local.name}"
  iam_role_policies = {
    AmazonEC2ContainerServiceforEC2Role = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
    AmazonSSMManagedInstanceCore        = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }

  vpc_zone_identifier       = module.vpc.private_subnets
  health_check_type         = "EC2"
  health_check_grace_period = var.health_check_grace_period

  min_size         = var.autoscaling_min_size
  max_size         = var.autoscaling_max_size
  desired_capacity = var.autoscaling_desired_capacity

  initial_lifecycle_hooks = [
    {
      name                 = "EC2StartupLifeCycleHook"
      default_result       = "CONTINUE"
      heartbeat_timeout    = var.initial_lifecycle_hooks_heartbeat_timeout
      lifecycle_transition = "autoscaling:EC2_INSTANCE_LAUNCHING"
    }
  ]

  # https://github.com/hashicorp/terraform-provider-aws/issues/12582
  autoscaling_group_tags = {
    AmazonECSManaged = true
  }

  # Required for  managed_termination_protection = "ENABLED"
  protect_from_scale_in = true

  # Spot instances
  use_mixed_instances_policy = each.value.use_mixed_instances_policy
  mixed_instances_policy     = each.value.mixed_instances_policy

  tags = local.tags
}

module "autoscaling_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = local.name
  description = "Autoscaling group security group"
  vpc_id      = module.vpc.vpc_id

  computed_ingress_with_source_security_group_id = [
    {
      rule                     = "http-80-tcp"
      source_security_group_id = module.alb_sg.security_group_id
    }
  ]
  number_of_computed_ingress_with_source_security_group_id = 1

  egress_rules = ["all-all"]

  tags = local.tags
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 4.0"

  name = local.name
  cidr = local.vpc_cidr

  azs             = local.azs
  private_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 4, k)] // https://developer.hashicorp.com/terraform/language/functions/cidrsubnet
  public_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 48)]

  enable_nat_gateway = true
  single_nat_gateway = true

  tags = local.tags
}
