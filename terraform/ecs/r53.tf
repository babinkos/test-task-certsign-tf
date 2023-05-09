provider "aws" {
  region = "eu-west-2" # GB
}

locals {
  zone_id = var.r53_zone_id # public R53 zone
}

resource "aws_route53_health_check" "eu" {
  fqdn              = module.ecs_cluster_eu.alb_dns
  port              = 80
  type              = "HTTP"
  resource_path     = "/healthz/r53"
  failure_threshold = "3"
  request_interval  = "30"
  regions           = ["eu-west-1", "us-west-2", "us-east-1"] # from: [us-west-1 us-west-2 us-east-1 eu-west-1 sa-east-1 ap-southeast-1 ap-southeast-2 ap-northeast-1]
  tags = {
    Name = "tf-test-health-check-eu"
  }
}
resource "aws_route53_health_check" "us" {
  fqdn              = module.ecs_cluster_us.alb_dns
  port              = 80
  type              = "HTTP"
  resource_path     = "/healthz/r53"
  failure_threshold = "2"
  request_interval  = "30"
  regions           = ["us-west-1", "us-west-2", "us-east-1"]
  tags = {
    Name = "tf-test-health-check-eu"
  }
}
module "records" {
  source  = "terraform-aws-modules/route53/aws//modules/records"
  version = "~> 2.0"
  # zone_name = local.zone_name
  zone_id = local.zone_id

  records = [
    {
      name            = "eu-failover-primary"
      type            = "A"
      set_identifier  = "eu-failover-primary"
      health_check_id = resource.aws_route53_health_check.eu.id # aws_route53_health_check.failover.id
      alias = {
        name                   = module.ecs_cluster_eu.alb_dns
        zone_id                = module.ecs_cluster_eu.alb_zone_id
        evaluate_target_health = true
      }
      failover_routing_policy = {
        type = "PRIMARY"
      }
    },
    {
      name           = "eu-failover-secondary"
      type           = "A"
      set_identifier = "eu-failover-secondary"
      alias = {
        name                   = module.ecs_cluster_us.alb_dns
        zone_id                = module.ecs_cluster_us.alb_zone_id
        evaluate_target_health = true
      }
      failover_routing_policy = {
        type = "SECONDARY"
      }
    },
    {
      name            = "us-failover-primary"
      type            = "A"
      set_identifier  = "us-failover-primary"
      health_check_id = resource.aws_route53_health_check.us.id # aws_route53_health_check.failover.id
      alias = {
        name                   = module.ecs_cluster_us.alb_dns
        zone_id                = module.ecs_cluster_us.alb_zone_id
        evaluate_target_health = true
      }
      failover_routing_policy = {
        type = "PRIMARY"
      }
    },
    {
      name           = "us-failover-secondary"
      type           = "A"
      set_identifier = "us-failover-secondary"
      alias = {
        name                   = module.ecs_cluster_eu.alb_dns
        zone_id                = module.ecs_cluster_eu.alb_zone_id
        evaluate_target_health = true
      }
      failover_routing_policy = {
        type = "SECONDARY"
      }
    },
    {
      name = "geotest"
      type = "A"
      # ttl  = 5
      alias = {
        name                   = "eu-failover-primary.babinkos.de"
        zone_id                = local.zone_id
        evaluate_target_health = true
      }
      set_identifier = "geo-failback-europe-eu"
      geolocation_routing_policy = {
        # AF: Africa, AN: Antarctica, AS: Asia, EU: Europe, OC: Oceania, NA: North America, SA: South America
        continent = "EU", # https://docs.aws.amazon.com/Route53/latest/APIReference/API_GetGeoLocation.html
      }
    },
    {
      name = "geotest"
      type = "A"
      # ttl  = 5
      alias = {
        name                   = "eu-failover-primary.babinkos.de"
        zone_id                = local.zone_id
        evaluate_target_health = true
      }
      set_identifier = "geo-failback-europe-as"
      geolocation_routing_policy = {
        continent = "AS",
      }
    },
    {
      name = "geotest"
      type = "A"
      # ttl  = 5
      alias = {
        name                   = "eu-failover-primary.babinkos.de"
        zone_id                = local.zone_id
        evaluate_target_health = true
      }
      set_identifier = "geo-failback-europe-af"
      geolocation_routing_policy = {
        # AF: Africa, AN: Antarctica, AS: Asia, EU: Europe, OC: Oceania, NA: North America, SA: South America
        continent = "AF"
      }
    },
    {
      name = "geotest"
      type = "A"
      # ttl  = 5
      alias = {
        name                   = "us-failover-primary.babinkos.de"
        zone_id                = local.zone_id
        evaluate_target_health = true
      }
      set_identifier = "geo-failback-northamerica-na"
      geolocation_routing_policy = {
        continent = "NA",
      }
    },
    {
      name = "geotest"
      type = "A"
      # ttl  = 5
      alias = {
        name                   = "us-failover-primary.babinkos.de"
        zone_id                = local.zone_id
        evaluate_target_health = true
      }
      set_identifier = "geo-failback-northamerica-sa"
      geolocation_routing_policy = {
        continent = "SA",
      }
      }, {
      name = "geotest"
      type = "A"
      # ttl  = 5
      alias = {
        name                   = "us-failover-primary.babinkos.de"
        zone_id                = local.zone_id
        evaluate_target_health = true
      }
      set_identifier = "geo-failback-northamerica-an"
      geolocation_routing_policy = {
        continent = "AN",
      }
      }, {
      name = "geotest"
      type = "A"
      # ttl  = 5
      alias = {
        name                   = "us-failover-primary.babinkos.de"
        zone_id                = local.zone_id
        evaluate_target_health = true
      }
      set_identifier = "geo-failback-northamerica-oc"
      geolocation_routing_policy = {
        continent = "OC"
      }
    },
  ]

  # depends_on = [module.zones]
}

