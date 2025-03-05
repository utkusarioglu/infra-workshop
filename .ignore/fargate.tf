data "aws_availability_zones" "available" {}

variable "region" {
  type = string
}

variable "cluster_code" {
  type = string
}

variable "cidr_block" {
  type = string
}

variable "tags" {
  description = "Tag given to each deployed Instance"
  type = object({
    Cluster      = string
    ClusterShort = string
    Platform     = string
    Region       = string
    RegionShort  = string
    Environment  = string
    Unit         = string
  })
}

locals {
  region = var.region
  name   = var.cluster_code

  vpc_cidr = var.cidr_block
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)

  container_name = "enjin"
  container_port = 80
  subdomain      = "enjino"

  tags = var.tags
}

################################################################################
# Cluster
################################################################################

module "ecs_cluster" {
  source = "terraform-aws-modules/ecs/aws//modules/cluster"

  cluster_name = "${local.name}-cluster"

  # Capacity provider
  fargate_capacity_providers = {
    # FARGATE = {
    #   default_capacity_provider_strategy = {
    #     weight = 50
    #     base   = 20
    #   }
    # }
    FARGATE_SPOT = {
      default_capacity_provider_strategy = {
        weight = 1
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

  name        = "${local.name}-service"
  cluster_arn = module.ecs_cluster.arn

  # cpu    = 1024
  # memory = 4096

  # Enables ECS Exec
  enable_execute_command = true

  # Container definition(s)
  container_definitions = {

    # fluent-bit = {
    #   cpu       = 512
    #   memory    = 1024
    #   essential = true
    #   image     = nonsensitive(data.aws_ssm_parameter.fluentbit.value)
    #   firelens_configuration = {
    #     type = "fluentbit"
    #   }
    #   memory_reservation = 50
    #   user               = "0"
    # }

    (local.container_name) = {
      cpu                = 102
      memory             = 1024
      memory_reservation = 100
      essential          = true
      image              = "nginx"
      port_mappings = [
        {
          name          = local.container_name
          containerPort = local.container_port
          hostPort      = local.container_port
          protocol      = "tcp"
        }
      ]

      # Example image used requires access to write to root filesystem
      readonly_root_filesystem = false

      # dependencies = [{
      #   containerName = "fluent-bit"
      #   condition     = "START"
      # }]

      enable_cloudwatch_logging = true
      # log_configuration = {
      #   logDriver = "awsfirelens"
      #   options = {
      #     Name                    = "firehose"
      #     region                  = local.region
      #     delivery_stream         = "my-stream"
      #     log-driver-buffer-limit = "2097152"
      #   }
      # }

      # linux_parameters = {
      #   capabilities = {
      #     add = []
      #     drop = [
      #       "NET_RAW"
      #     ]
      #   }
      # }

      # Not required for fluent-bit, just an example
      # volumes_from = [{
      #   sourceContainer = "fluent-bit"
      #   readOnly        = false
      # }]
      # mount_points = [
      #   {
      #     source_volume  = "epho"
      #     container_path = "/var/cache/nginx"
      #   }
      # ]
    }

  }

  # ephemeral_storage = {
  #   size_in_gib : 21
  # }

  # volume = [
  #   {
  #     name = "epho"
  #     ephemeral = {
  #       size_in_gb = 1 # Size of the ephemeral volume in GiB
  #     }
  #   }
  # ]

  /*
  needed if the service needs to communicate with others
  */
  service_connect_configuration = {
    namespace = aws_service_discovery_http_namespace.this.arn
    service = {
      client_alias = {
        port     = local.container_port
        dns_name = local.container_name
      }
      port_name      = local.container_name
      discovery_name = local.container_name
    }
  }

  load_balancer = {
    service = {
      target_group_arn = module.alb.target_groups["ex_ecs"].arn
      container_name   = local.container_name
      container_port   = local.container_port
    }
  }

  subnet_ids = module.vpc.private_subnets
  security_group_rules = {
    alb_ingress = {
      type                     = "ingress"
      from_port                = local.container_port
      to_port                  = local.container_port
      protocol                 = "tcp"
      description              = "Service port"
      source_security_group_id = module.alb.security_group_id
    }
    egress_all = {
      type        = "egress"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  service_tags = local.tags
  tags         = local.tags
}

################################################################################
# Supporting Resources
################################################################################

# data "aws_ssm_parameter" "fluentbit" {
#   name = "/aws/service/aws-for-fluent-bit/stable"
# }

# resource "aws_service_discovery_http_namespace" "this" {
#   name        = local.name
#   description = "CloudMap namespace for ${local.name}"
#   tags        = local.tags
# }

module "alb" {
  source = "terraform-aws-modules/alb/aws"
  # version = "~> 9.0"

  name                       = local.name
  load_balancer_type         = "application"
  vpc_id                     = module.vpc.vpc_id
  subnets                    = module.vpc.public_subnets
  enable_deletion_protection = false

  # Security Group
  security_group_ingress_rules = {
    all_http = {
      from_port   = 80
      to_port     = 80
      ip_protocol = "tcp"
      cidr_ipv4   = "0.0.0.0/0"
    }
    all_https = {
      from_port   = 443
      to_port     = 443
      ip_protocol = "tcp"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }
  security_group_egress_rules = {
    all = {
      ip_protocol = "-1"
      cidr_ipv4   = module.vpc.vpc_cidr_block
    }
  }

  listeners = {
    ex_http_https_redirect = {
      port     = 80
      protocol = "HTTP"
      redirect = {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301" // maybe 308?
      }
    }
    ex_https = {
      port            = 443
      protocol        = "HTTPS"
      certificate_arn = module.cert.acm_certificate_arn

      forward = {
        target_group_key = "ex_ecs"
      }
    }
  }

  target_groups = {
    ex_ecs = {
      backend_protocol                  = "HTTP"
      backend_port                      = local.container_port
      target_type                       = "ip"
      deregistration_delay              = 5
      load_balancing_cross_zone_enabled = true

      health_check = {
        enabled             = true
        healthy_threshold   = 5
        interval            = 30
        matcher             = "200"
        path                = "/"
        port                = "traffic-port"
        protocol            = "HTTP"
        timeout             = 5
        unhealthy_threshold = 2
      }

      # There's nothing to attach here in this definition. Instead,
      # ECS will attach the IPs of the tasks to this target group
      create_attachment = false
    }
  }

  route53_records = {
    A = {
      type    = "A"
      name    = local.subdomain
      zone_id = data.aws_route53_zone.utku.zone_id
    }
  }

  tags = local.tags
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name               = local.name
  cidr               = local.vpc_cidr
  azs                = local.azs
  private_subnets    = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 4, k)]
  public_subnets     = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 48)]
  enable_nat_gateway = true
  single_nat_gateway = true
  tags               = local.tags
}

module "cert" {
  source = "terraform-aws-modules/acm/aws"

  domain_name         = "${local.subdomain}.utkusarioglu.com"
  zone_id             = data.aws_route53_zone.utku.zone_id
  validation_method   = "DNS"
  wait_for_validation = true
  tags                = var.tags
}

data "aws_route53_zone" "utku" {
  name = "utkusarioglu.com"
}

output "dns" {
  value = join(".", [
    module.alb.route53_records["A"].name,
    data.aws_route53_zone.utku.name
  ])
}
