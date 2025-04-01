module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.34.0"

  cluster_name    = var.cluster_name
  cluster_version = "1.32"

  vpc_id                                   = module.vpc.vpc_id
  subnet_ids                               = module.vpc.private_subnets
  control_plane_subnet_ids                 = module.vpc.private_subnets
  enable_irsa                              = true
  cluster_endpoint_public_access           = true
  cluster_endpoint_private_access          = true
  enable_cluster_creator_admin_permissions = true

  access_entries = {
    admin = {
      principal_arn = data.aws_iam_user.admin.arn
      policy_associations = {
        eks_admin = {
          policy_arn        = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSAdminPolicy"
          type              = "AWS" # Use "AWS" for IAM roles
          kubernetes_groups = ["system:masters"]
          access_scope = {
            type = "cluster"
          }
        }
        eks_cluster_admin = {
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

  cluster_addons = {
    eks-pod-identity-agent = {},
    aws-ebs-csi-driver     = {}
  }

  node_security_group_additional_rules = {
    ingress_allow_access_from_alb_sg = {
      type                     = "ingress"
      protocol                 = "-1"
      from_port                = 0
      to_port                  = 0
      source_security_group_id = module.sg_web.security_group_id
    }
  }

  eks_managed_node_groups = {
    default = {
      ami_type       = "BOTTLEROCKET_x86_64"
      instance_types = ["t3.medium"]
      capacity_type  = "SPOT"

      create_launch_template = true

      min_size = 1
      max_size = 2
      # This value is ignored after the initial creation
      # https://github.com/bryantbiggs/eks-desired-size-hack
      desired_size = 1

      iam_role_additional_policies = {
        Alb = aws_iam_policy.alb.arn
        EC2 = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
        Asg = "arn:aws:iam::aws:policy/AutoScalingFullAccess"
      }

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

  tags = var.tags
  # cluster_security_group_tags = var.tags
  # cluster_tags                = var.tags
  # iam_role_tags               = var.tags
  # node_iam_role_tags          = var.tags
  # node_security_group_tags    = var.tags
}

resource "aws_autoscaling_policy" "cpu_scale_out" {
  name                   = "default-group"
  policy_type            = "TargetTrackingScaling"
  autoscaling_group_name = module.eks.eks_managed_node_groups_autoscaling_group_names[0]

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 70
  }
}
