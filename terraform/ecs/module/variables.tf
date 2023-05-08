variable "region" {
  description = "region"
  type        = string
  default     = "eu-central-1"
}
variable "ecs_service_desired_count" {
  description = "ecs_service_desired_count"
  type        = number
  default     = 2
}
variable "ecs_service_cpu" {
  description = "ecs_service_cpu"
  type        = number
  default     = 128 # https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definition_parameters.html
}
variable "ecs_service_memory" {
  description = "ecs_service_memory"
  type        = number
  default     = 300
}
variable "autoscaling_min_capacity" {
  description = "autoscaling_min_capacity"
  type        = number
  default     = 2
}
variable "autoscaling_max_capacity" {
  description = "autoscaling_max_capacity"
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
  default     = 180
}
variable "container_definition_memory" {
  description = "container_definition_memory"
  type        = number
  default     = 300
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
  description = "Time (in seconds) after instance comes into service before checking health."
  type        = number
  default     = 300
}
variable "initial_lifecycle_hooks_heartbeat_timeout" {
  description = "The maximum time, in seconds, that can elapse before the lifecycle hook times out. The range is from 30 to 7200 seconds. The default value is 3600 seconds (1 hour)."
  type        = number
  default     = 180
}
