variable "region" {
  description = "region"
  type        = string
  default     = "eu-central-1"
}
# variable "ecs_service_desired_count" {
#   description = "ecs_service_desired_count"
#   type        = number
#   default     = 2
# }
variable "ecs_service_task_cpu" {
  description = "ecs_service_task_cpu"
  type        = number
  default     = 1024
}
variable "ecs_service_task_memory" {
  description = "ecs_service_task_memory"
  type        = number
  default     = 900
}
variable "ecs_service_min_capacity" {
  description = "ecs_service_min_capacity"
  type        = number
  default     = 2
}
variable "ecs_service_max_capacity" {
  description = "ecs_service_max_capacity"
  type        = number
  default     = 6
}
variable "container_definition_cpu" {
  description = "container_definition_cpu"
  type        = number
  default     = 1
}
variable "container_definition_memory_reservation" {
  description = "container_definition_memory_reservation"
  type        = number
  default     = 32
}
variable "container_definition_memory" {
  description = "container_definition_memory"
  type        = number
  default     = 64
}
variable "container_definition_image" {
  description = "container_definition_image"
  type        = string
  default     = "503110391064.dkr.ecr.eu-central-1.amazonaws.com/sign-svc:latest"
}
variable "autoscaling_instance_type" {
  description = "autoscaling_instance_type"
  type        = string
  default     = "t2.micro"
}
variable "autoscaling_min_size" {
  description = "autoscaling_min_size"
  type        = number
  default     = 2
}
variable "autoscaling_max_size" {
  description = "autoscaling_max_size"
  type        = number
  default     = 2
}
variable "autoscaling_desired_capacity" {
  description = "autoscaling_desired_capacity"
  type        = number
  default     = 2
}
variable "health_check_grace_period" {
  description = "The period of time, in seconds, that the Amazon ECS service scheduler ignores unhealthy Elastic Load Balancing target health checks after a task has first started."
  type        = number
  default     = 300
}
variable "initial_lifecycle_hooks_heartbeat_timeout" {
  description = "The maximum time, in seconds, that can elapse before the lifecycle hook times out. The range is from 30 to 7200 seconds. The default value is 3600 seconds (1 hour)."
  type        = number
  default     = 180
}
variable "alb_deregistration_delay" {
  description = " Amount time for Elastic Load Balancing to wait before changing the state of a deregistering target from draining to unused. The range is 0-3600 seconds. The default value is 300 seconds"
  type        = number
  default     = 300
}
variable "alb_load_balancing_algorithm_type" {
  description = " Determines how the load balancer selects targets when routing requests. Only applicable for Application Load Balancer Target Groups. The value is round_robin or least_outstanding_requests. The default is round_robin."
  type        = string
  default     = "least_outstanding_requests"
}
variable "alb_health_check_enabled" {
  description = "alb_health_check_enabled"
  type        = bool
  default     = true
}
variable "runtime_platform" {
  description = "Configuration block for `runtime_platform` that containers in your task may use"
  type        = any
  default = {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }
}
variable "alb_health_check_interval" {
  description = "alb_health_check_interval"
  type        = number
  default     = 30
}
variable "alb_health_check_healthy_threshold" {
  description = "alb_health_check_healthy_threshold"
  type        = number
  default     = 2
}
variable "alb_health_check_unhealthy_threshold" {
  description = "alb_health_check_unhealthy_threshold"
  type        = number
  default     = 6
}
variable "alb_health_check_timeout" {
  description = "alb_health_check_interval"
  type        = number
  default     = 10
}
variable "ecs_optimized_ami_filter" {
  description = "Linux Amazon ECS-optimized AMIs metadata path"
  type        = string
  default     = "/aws/service/ecs/optimized-ami/amazon-linux-2023/recommended" # https://docs.aws.amazon.com/AmazonECS/latest/developerguide/retrieve-ecs-optimized_AMI.html
}
variable "ecs_asg_target_capacity" {
  description = "ecs_asg_target_capacity"
  type        = number
  default     = 80
}
variable "r53_zone_id" {
  description = "Route53 Public DNS zone id"
  type        = string
  default     = ""
}
variable "cert_validity_days_cap" {
  description = "cert_validity_days_cap"
  type        = number
  default     = 3
}
variable "acm_certificate_arn_eu" {
  description = "acm_certificate_arn"
  type        = string
  default     = ""
}
variable "acm_certificate_arn_us" {
  description = "acm_certificate_arn"
  type        = string
  default     = ""
}
