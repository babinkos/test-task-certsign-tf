module "ecs_cluster_eu" {
  source                                  = "./module"
  region                                  = "eu-central-1"
  ecs_service_task_cpu                    = var.ecs_service_task_cpu # For tasks that run on EC2 or external instances, this field is optional. If your cluster doesn't have any registered container instances with the requested CPU units available, the task fails. Supported values for tasks that run on EC2 or external instances are between 128 CPU units (0.125 vCPUs) and 10240 CPU units (10 vCPUs).
  ecs_service_task_memory                 = var.ecs_service_task_memory
  container_definition_memory_reservation = var.container_definition_memory_reservation # VSS/RAM of running app
  container_definition_memory             = var.container_definition_memory
  autoscaling_min_size                    = var.autoscaling_min_size
  autoscaling_max_size                    = var.autoscaling_max_size
  ecs_service_min_capacity                = var.ecs_service_min_capacity # Minimum number of tasks to run in your service

  # cpu: Tracking ECSServiceAverageCPUUtilization at 75
  # memory: Tracking ECSServiceAverageMemoryUtilization at 75
  ecs_service_max_capacity = var.ecs_service_max_capacity # Maximum number of tasks to run in your service

  container_definition_image = var.container_definition_image # tags : amd64 | arm64

  autoscaling_instance_type = var.autoscaling_instance_type # t2.micro (1 GB/ 1 vCPU) | t4g.small (2 GB/ 2 vCPU), arch = X86_64 | ARM64
  runtime_platform          = var.runtime_platform
  # "/aws/service/ecs/optimized-ami/amazon-linux-2023/recommended" or "/aws/service/ecs/optimized-ami/amazon-linux-2023/arm64/recommended" :
  ecs_optimized_ami_filter = var.ecs_optimized_ami_filter

  health_check_grace_period                 = var.health_check_grace_period
  initial_lifecycle_hooks_heartbeat_timeout = var.initial_lifecycle_hooks_heartbeat_timeout
  alb_deregistration_delay                  = var.alb_deregistration_delay
  alb_health_check_enabled                  = var.alb_health_check_enabled
  alb_health_check_interval                 = var.alb_health_check_interval            # The range is 5–300 seconds
  alb_health_check_healthy_threshold        = var.alb_health_check_healthy_threshold   # The range is 2–10
  alb_health_check_unhealthy_threshold      = var.alb_health_check_unhealthy_threshold #  The range is 2–10
  alb_health_check_timeout                  = var.alb_health_check_timeout             # The range is 2–120
  cert_validity_days_cap                    = var.cert_validity_days_cap
  acm_certificate_arn                       = var.acm_certificate_arn
}
module "ecs_cluster_us" {
  source                                  = "./module"
  region                                  = "us-east-2"
  container_definition_image              = "503110391064.dkr.ecr.us-east-2.amazonaws.com/sign-svc:amd64"
  ecs_service_task_cpu                    = var.ecs_service_task_cpu # For tasks that run on EC2 or external instances, this field is optional. If your cluster doesn't have any registered container instances with the requested CPU units available, the task fails. Supported values for tasks that run on EC2 or external instances are between 128 CPU units (0.125 vCPUs) and 10240 CPU units (10 vCPUs).
  ecs_service_task_memory                 = var.ecs_service_task_memory
  container_definition_memory_reservation = var.container_definition_memory_reservation # VSS/RAM of running app
  container_definition_memory             = var.container_definition_memory
  autoscaling_min_size                    = var.autoscaling_min_size
  autoscaling_max_size                    = var.autoscaling_max_size
  ecs_service_min_capacity                = var.ecs_service_min_capacity # Minimum number of tasks to run in your service

  # cpu: Tracking ECSServiceAverageCPUUtilization at 75
  # memory: Tracking ECSServiceAverageMemoryUtilization at 75
  ecs_service_max_capacity = var.ecs_service_max_capacity # Maximum number of tasks to run in your service

  # container_definition_image = var.container_definition_image # tags : amd64 | arm64

  autoscaling_instance_type = var.autoscaling_instance_type # t2.micro (1 GB/ 1 vCPU) | t4g.small (2 GB/ 2 vCPU), arch = X86_64 | ARM64
  runtime_platform          = var.runtime_platform
  # "/aws/service/ecs/optimized-ami/amazon-linux-2023/recommended" or "/aws/service/ecs/optimized-ami/amazon-linux-2023/arm64/recommended" :
  ecs_optimized_ami_filter = var.ecs_optimized_ami_filter

  health_check_grace_period                 = var.health_check_grace_period
  initial_lifecycle_hooks_heartbeat_timeout = var.initial_lifecycle_hooks_heartbeat_timeout
  alb_deregistration_delay                  = var.alb_deregistration_delay
  alb_health_check_enabled                  = var.alb_health_check_enabled
  alb_health_check_interval                 = var.alb_health_check_interval            # The range is 5–300 seconds
  alb_health_check_healthy_threshold        = var.alb_health_check_healthy_threshold   # The range is 2–10
  alb_health_check_unhealthy_threshold      = var.alb_health_check_unhealthy_threshold #  The range is 2–10
  alb_health_check_timeout                  = var.alb_health_check_timeout             # The range is 2–120
  cert_validity_days_cap                    = var.cert_validity_days_cap
  acm_certificate_arn                       = var.acm_certificate_arn
}
