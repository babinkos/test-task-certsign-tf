# region                                  = "eu-central-1"
ecs_service_cpu                         = 1024 # For tasks that run on EC2 or external instances, this field is optional. If your cluster doesn't have any registered container instances with the requested CPU units available, the task fails. Supported values for tasks that run on EC2 or external instances are between 128 CPU units (0.125 vCPUs) and 10240 CPU units (10 vCPUs).
ecs_service_memory                      = 82
container_definition_memory_reservation = 32 # VSS/RAM of running app
container_definition_memory             = 82
autoscaling_min_size                    = 2
autoscaling_max_size                    = 3
autoscaling_min_capacity                = 2  # Minimum number of tasks to run in your service
autoscaling_max_capacity                = 10 # Maximum number of tasks to run in your service

container_definition_image = "503110391064.dkr.ecr.eu-central-1.amazonaws.com/sign-svc:arm64" # tags : amd64 | arm64

autoscaling_instance_type = "t4g.small" # t2.micro (1 GB/ 1 vCPU) | t4g.small (2 GB/ 2 vCPU), arch = X86_64 | ARM64
runtime_platform = {
  "operatingSystemFamily" : "LINUX",
  "cpuArchitecture" : "ARM64"
}
# "/aws/service/ecs/optimized-ami/amazon-linux-2023/recommended" or "/aws/service/ecs/optimized-ami/amazon-linux-2023/arm64/recommended" :
ecs_optimized_ami_filter = "/aws/service/ecs/optimized-ami/amazon-linux-2023/arm64/recommended"

# The period of time, in seconds, that the Amazon ECS service scheduler ignores unhealthy Elastic Load Balancing target health checks
#  after a task has first started. This is only used when your service is configured to use a load balancer. 
#  If your service has a load balancer defined and you don't specify a health check grace period value, the default value of 0 is used.
# If your service's tasks take a while to start and respond to Elastic Load Balancing health checks, you can specify
#  a health check grace period of up to 2,147,483,647 seconds (about 69 years). During that time, the Amazon ECS service scheduler ignores
#   health check status. This grace period can prevent the service scheduler from marking tasks as unhealthy and stopping them before
#    they have time to come up.
health_check_grace_period                 = 600
initial_lifecycle_hooks_heartbeat_timeout = 90
alb_deregistration_delay                  = 120
alb_health_check_enabled                  = true
alb_health_check_interval                 = 120 # The range is 5–300 seconds
alb_health_check_healthy_threshold        = 2   # The range is 2–10
alb_health_check_unhealthy_threshold      = 5   #  The range is 2–10
alb_health_check_timeout                  = 118 # The range is 2–120