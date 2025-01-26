output "azs" {
  value = data.aws_availability_zones.available_azs
}

output "vpc" {
  value = module.vpc
}
