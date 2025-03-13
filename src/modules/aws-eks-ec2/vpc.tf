module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name            = var.cluster_name
  cidr            = local.vpc_cidr
  azs             = local.azs
  private_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 4, k)]
  public_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 48)]

  enable_dns_support   = true
  enable_dns_hostnames = true
  enable_nat_gateway   = true
  single_nat_gateway   = true

  public_subnet_tags = merge(
    var.tags,
    {
      "kubernetes.io/role/elb"                    = 1
      "kubernetes.io/cluster/${var.cluster_name}" = "owned"
    }
  )

  private_subnet_tags = merge(
    var.tags,
    {
      "kubernetes.io/role/internal-elb"           = 1
      "kubernetes.io/cluster/${var.cluster_name}" = "owned"
    }
  )

  tags = merge(
    var.tags,
    {
      "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    }
  )
}
