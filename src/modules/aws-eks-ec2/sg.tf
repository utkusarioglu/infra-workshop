module "sg_web" {
  source = "terraform-aws-modules/security-group/aws//modules/web"

  name   = "alb-sg-web"
  vpc_id = module.vpc.vpc_id
  auto_ingress_rules = [
    "http-80-tcp",
    "https-443-tcp",
  ]
  ingress_cidr_blocks = ["0.0.0.0/0"]

  tags = var.tags
}
