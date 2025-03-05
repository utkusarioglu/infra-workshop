variable "cluster_name" {
  type = string
}

variable "region" {
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


data "aws_availability_zones" "available" {
  # Exclude local zones
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

locals {
  name   = var.cluster_name
  region = var.region

  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)

  tags = var.tags

  autoscaling_average_cpu = 30
  # ebs_csi_service_account_namespace = "kube-system"
  # ebs_csi_service_account_name      = "ebs-csi-controller-sa"
}

################################################################################
# VPC
################################################################################
resource "aws_eip" "nat_gw_elastic_ip" {
  tags = {
    Name = "${local.name}-nat-eip"
  }
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  # version = "~> 5.0"

  name = local.name
  cidr = local.vpc_cidr

  azs             = local.azs
  private_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 4, k)]
  public_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 48)]
  intra_subnets   = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 52)]

  enable_nat_gateway = true
  single_nat_gateway = true

  public_subnet_tags = {
    "kubernetes.io/role/elb"              = 1
    "kubernetes.io/cluster/${local.name}" = "owned"
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb"     = 1
    "kubernetes.io/cluster/${local.name}" = "owned"
  }

  tags = merge(
    local.tags,
    {
      "kubernetes.io/cluster/${local.name}" = "shared"
    }
  )
}

module "eks" {
  source = "terraform-aws-modules/eks/aws"


  cluster_name    = local.name
  cluster_version = "1.32"

  cluster_endpoint_public_access           = true
  cluster_endpoint_private_access          = false
  enable_cluster_creator_admin_permissions = true

  # authentication_mode                      = "API_AND_CONFIG_MAP"
  access_entries = {
    utku = {
      principal_arn = "arn:aws:iam::731522355899:user/utkusarioglu"
      policy_associations = {
        example = {
          policy_arn        = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSAdminPolicy"
          type              = "AWS" # Use "AWS" for IAM roles
          kubernetes_groups = ["system:masters"]
          access_scope = {
            type = "cluster"
          }
        }
        example = {
          policy_arn        = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          type              = "AWS" # Use "AWS" for IAM roles
          kubernetes_groups = ["system:masters"]
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
  }

  # coredns, kube-proxy, and vpc-cni are automatically installed by EKS         
  cluster_addons = {
    eks-pod-identity-agent = {},
    aws-ebs-csi-driver     = {}
  }

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  # cluster_compute_config = {
  #   enabled    = true
  #   node_pools = ["general-purpose"]

  #   create_spot_instance      = true
  #   spot_price                = "0.0038"
  #   spot_type                 = "persistent"
  #   spot_wait_for_fulfillment = true
  # }


  eks_managed_node_groups = {
    default = {
      ami_type       = "BOTTLEROCKET_x86_64"
      instance_types = ["t3.small"]
      capacity_type  = "SPOT"

      # create_spot_instance      = true
      spot_wait_for_fulfillment = true
      spot_price                = "0.0038"
      spot_type                 = "persistent"

      create_launch_template = true

      min_size = 1
      max_size = 2
      # This value is ignored after the initial creation
      # https://github.com/bryantbiggs/eks-desired-size-hack
      desired_size = 1

      iam_role_additional_policies = {
        Alb = aws_iam_policy.alb.arn
      }

      # iam_role_policy_statements = {
      #   alb = data.http.policy
      # }

      # This is not required - demonstrates how to pass additional configuration
      # Ref https://bottlerocket.dev/en/os/1.19.x/api/settings/
      bootstrap_extra_args = <<-EOT
        # The admin host container provides SSH access and runs with "superpowers".
        # It is disabled by default, but can be disabled explicitly.
        [settings.host-containers.admin]
        enabled = false

        # The control host container provides out-of-band access via SSM.
        # It is enabled by default, and can be disabled if you do not expect to use SSM.
        # This could leave you with no way to access the API and change settings on an existing node!
        [settings.host-containers.control]
        enabled = true

        # extra args added
        [settings.kernel]
        lockdown = "integrity"
      EOT
    }
  }
}

provider "http" {

}

resource "aws_iam_policy" "alb" {
  name   = "alb"
  policy = data.http.alb_policy.response_body
}

data "http" "alb_policy" {
  url = "https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.2.1/docs/install/iam_policy.json"
}


output "vpc_id" {
  value = module.vpc.vpc_id
}
