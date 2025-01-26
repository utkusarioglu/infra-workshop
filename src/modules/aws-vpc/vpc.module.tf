module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.17.0"

  name = "${var.cluster_code}-vpc"
  cidr = "10.0.0.0/16"

  azs             = local.azs
  private_subnets = [for i in range(0, length(local.azs)) : cidrsubnet("10.0.0.0/24", 2, i)]
  public_subnets  = [for i in range(0, length(local.azs)) : cidrsubnet("10.0.100.0/24", 2, i)]

  enable_nat_gateway = false
  enable_vpn_gateway = false

  tags = var.tags
}
