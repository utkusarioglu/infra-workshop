locals {
  vpc_cidr                = "10.0.0.0/16"
  azs                     = slice(data.aws_availability_zones.available.names, 0, 3)
  tags                    = var.tags
  autoscaling_average_cpu = 30
}
