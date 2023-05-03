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
  default     = 1024
}
variable "ecs_service_memory" {
  description = "ecs_service_memory"
  type        = number
  default     = 900
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
