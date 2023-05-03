region                                  = "eu-central-1"
ecs_service_desired_count               = 2 # Number of instances of the task definition to place and keep running
ecs_service_cpu                         = 1024
ecs_service_memory                      = 900 # if unset defaults to 2GB wich is more that 1GB for t2.micro
container_definition_cpu                = 1   # 1 vCPU = 1024
container_definition_memory_reservation = 32  # Soft limit to be reserbed
container_definition_memory             = 64  # Hard limit, OOMKill on exceed
container_definition_image              = "503110391064.dkr.ecr.eu-central-1.amazonaws.com/sign-svc:latest"
autoscaling_instance_type               = "t2.micro"
autoscaling_min_size                    = 2
autoscaling_max_size                    = 2
autoscaling_desired_capacity            = 2