output "vpc_id" {
  value = module.vpc.vpc_id
}

output "alb_security_group_id" {
  value = module.sg_web.security_group_id
}
