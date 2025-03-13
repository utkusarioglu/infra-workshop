module "eks" {
  source = "terraform-aws-modules/eks/aws"

  cluster_name    = var.cluster_name
  cluster_version = "1.32"

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

  # coredns, kube-proxy, and vpc-cni are automatically installed by EKS         
  cluster_addons = {
    eks-pod-identity-agent = {},
    aws-ebs-csi-driver     = {}
  }

  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.private_subnets
  control_plane_subnet_ids = module.vpc.private_subnets

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

      create_spot_instance      = true
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
        EC2 = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
        Asg = "arn:aws:iam::aws:policy/AutoScalingFullAccess"
      }

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

  tags = var.tags
  # cluster_security_group_tags = var.tags
  # cluster_tags                = var.tags
  # iam_role_tags               = var.tags
  # node_iam_role_tags          = var.tags
  # node_security_group_tags    = var.tags
}

resource "aws_autoscaling_policy" "cpu_scale_out" {
  name        = "default-group"
  policy_type = "TargetTrackingScaling"
  # autoscaling_group_name = "default"
  autoscaling_group_name = module.eks.eks_managed_node_groups_autoscaling_group_names[0]

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 70 # Scale out when CPU usage > 70%
  }
}

# module "asg" {
#   source = "terraform-aws-modules/autoscaling/aws"

#   name                = "eks-asg"
#   use_name_prefix     = false
#   min_size           = 1
#   max_size           = 5
#   desired_capacity   = 2
#   wait_for_capacity_timeout = "0"

#   # Link the Auto Scaling Group Name from EKS
#   autoscaling_group_name = module.eks.eks_managed_node_groups_autoscaling_group_names["default"]

#   scaling_policies = {
#     scale-out = {
#       policy_type            = "TargetTrackingScaling"
#       estimated_instance_warmup = 180
#       target_tracking_configuration = {
#         predefined_metric_specification = {
#           predefined_metric_type = "ASGAverageCPUUtilization"
#         }
#         target_value = 70  # Scale out when CPU utilization > 70%
#       }
#     }
#   }
# }
