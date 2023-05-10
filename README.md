# test-task-certsign-tf

## Network Design

- 1 region to run ECS in EU : "eu-central-1"
- 1 region to run ECS in US : "us-east-2"
- 1 Global R53 AWS hosted Public zone to have geolocation and failover DNS records pointing to ALB created with ECS module.

## Pre-requisites

### AWS Route53 Public DNS zone

Once registered, zone_id should be provided in ecs.auto.tfvars as variable r53_zone_id value
Example domain:
`babinkos.de`

### AWS ACM Amazon-issued certificates in EU and US zones

Once issued should be provided in ecs.auto.tfvars as variable acm_certificate_arn_eu, acm_certificate_arn_us values

List of domains added to certificate:
- geotest.babinkos.de
- us-failover-secondary.babinkos.de
- eu-failover-primary.babinkos.de
- eu-failover-secondary.babinkos.de
- us-failover-primary.babinkos.de

For tests it might be a good idea to add ALB FQND wildcard domain as well.


### AWS ECR created in EU and US zones, container image prepared and stored

Generate CA certificate in test-task-certsign-server-py repo with prepare-ca-crt.sh

Build container image from Dockerfile in test-task-certsign-server-py repo, tag and push to both registries, provide full image name and tag in ecs.auto.tfvars as container_definition_image_eu and container_definition_image_us respectfully.


### Prepare test-task-csr-client-py to run tests

If needed - generate certificate requests with prepare_csr.sh
Install K6, see https://k6.io/docs/get-started/installation/

To verify ECS solution works you can use one of commands:
```
curl -v 'http://geotest.babinkos.de/health'
curl -v 'http://eu-failover-primary.babinkos.de/health'
curl -v 'http://us-failover-primary.babinkos.de/health'
```

Simple test wich will report missing csr:
`curl -v -X PUT -H "Content-Type: application/json" 'https://eu-failover-primary.babinkos.de/cert/sign' -d '{"name":"test2","csr":"none"}'`

Test to sign real csr:
`curl -v -X PUT -H "Content-Type: application/json" 'https://geotest.babinkos.de/cert/sign' -d @test-curl-data.json`

To run load test to have test automatic scalling run K6s with this one of commands below:
- `k6 run k6-script.js`
- `docker run --rm -i -v ./certs:/certs:ro grafana/k6 run - <k6-script.js`

There is an option to run K6 with web-dashboard, but it requires building with Go locally:
```
go version
go install go.k6.io/xk6/cmd/xk6@latest
xk6 build --with github.com/szkiba/xk6-dashboard@latest
./k6 run k6-script.js --out dashboard
```


## Deployment

Once prerequisites configured, run this command:
`terraform --apply`

To deploy only in one region (EU) run Terraform this way:
`terraform apply --target module.ecs_cluster_eu [other options]`


## Vertical scaling-up

In Free-Tier t2.micro (1 vCPU/2GB) and t4g.small (2 vCPU/2GB) available, to switch to Graviton - build ARM64 arch container image, tag, push it to registries and and update `ecs.auto.tfvars` and change variables `runtime_platform` and `ecs_optimized_ami_filter` to arm64 related values.

If Free-tier is no limitation - just set any desired instance size bigger than t2.micro (in the example - t2.small), this can be overriden in comman-line parameters this way :
`terraform apply -var 'autoscaling_instance_type="t2.small"'`
or
`terraform apply --target module.ecs_cluster_eu -var 'autoscaling_instance_type="t2.small"'`


## Horizontal scaling-up

To update maximum instances in ASG - change variable autoscaling_max_size in ecs.auto.tfvars or override value in command-line this way :
`terraform apply -var 'autoscaling_max_size=10'`

In case ECS service task number limit is insufficient - update variable ecs_service_max_capacity value in ecs.auto.tfvars or override value in command-line this way :
`terraform apply -var 'ecs_service_max_capacity=50'`

To apply changes only in one region (EU) run Terraform this way:
`terraform apply --target module.ecs_cluster_eu [other options]`


## Cleanup

1. Run terraform destroy, most likely ECS service will not be deleted, proceed with next steps then.
2. Update Min and Desired instance count in [ASG|https://eu-central-1.console.aws.amazon.com/ec2/home?region=eu-central-1#AutoScalingGroups] to 0. Remove instance scale-in protection
3. Terminate EC2 instances.
