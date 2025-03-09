module "eks" {
  source = "terraform-aws-modules/eks/aws"


  cluster_name    = local.name
  cluster_version = "1.32"

  enable_irsa                              = true
  cluster_endpoint_public_access           = true
  cluster_endpoint_private_access          = true
  enable_cluster_creator_admin_permissions = true

  # authentication_mode                      = "API_AND_CONFIG_MAP"
  access_entries = {
    utku = {
      // TODO you should be retrieving through terragrunt
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

  # cluster_security_group_additional_rules = {
  #   // BROKEN
  #   allow_all_node_to_node = {
  #     type      = "ingress"
  #     from_port = 0
  #     to_port   = 0
  #     protocol  = "-1"
  #     self      = true
  #     # security_group_id        = module.eks.cluster_security_group_id
  #     # source_security_group_id = module.eks.cluster_security_group_id
  #   }

  #   // BROKEN
  #   worker_to_control_plane = {
  #     type      = "egress"
  #     from_port = 443
  #     to_port   = 443
  #     protocol  = "tcp"
  #     self      = true
  #     # security_group_id             = module.eks.cluster_security_group_id
  #     # destination_security_group_id = module.eks.cluster_security_group_id
  #   }
  # }

  node_security_group_additional_rules = {
    # https://github.com/kubernetes-sigs/aws-load-balancer-controller/issues/2039#issuecomment-1099032289
    # ingress_allow_access_from_control_plane = {
    #   type                     = "ingress"
    #   protocol                 = "tcp"
    #   from_port                = 9443
    #   to_port                  = 9443
    #   source_security_group_id = module.eks.cluster_security_group_id
    #   # source_cluster_security_group = true
    # }

    # ingress_allow_access_from_alb_sg = {
    #   type                     = "ingress"
    #   protocol                 = "-1"
    #   from_port                = 0
    #   to_port                  = 0
    #   source_security_group_id = aws_security_group.alb.id
    # }
    # egress_all = {
    #   protocol         = "-1"
    #   from_port        = 0
    #   to_port          = 0
    #   type             = "egress"
    #   cidr_blocks      = ["0.0.0.0/0"]
    #   ipv6_cidr_blocks = ["::/0"]
    # }

    # allow connections from EKS to EKS (internal calls)
    # ingress_self_all = {
    #   protocol  = "-1"
    #   from_port = 0
    #   to_port   = 0
    #   type      = "ingress"
    #   self      = true
    # }

    # allow_dns_ingress = {
    #   type                     = "ingress"
    #   from_port                = 53
    #   to_port                  = 53
    #   protocol                 = "udp"
    #   security_group_id        = module.eks.cluster_security_group_id
    #   source_security_group_id = module.eks.cluster_security_group_id
    # }

    # allow_dns_egress = {
    #   type              = "egress"
    #   from_port         = 53
    #   to_port           = 53
    #   protocol          = "udp"
    #   security_group_id = module.eks.cluster_security_group_id
    #   cidr_blocks       = ["0.0.0.0/0"]
    # }


    # node_to_node = {
    #   type      = "ingress"
    #   from_port = 0
    #   to_port   = 65535
    #   protocol  = "tcp"
    #   # security_group_id        = aws_security_group.worker_node_sg.id
    #   # source_security_group_id = aws_security_group.worker_node_sg.id
    #   security_group_id        = module.eks.node_security_group_id
    #   source_security_group_id = module.eks.node_security_group_id
    # }

    # dns = {
    #   type                          = "egress"
    #   from_port                     = 53
    #   to_port                       = 53
    #   protocol                      = "udp"
    #   security_group_id             = module.eks.node_security_group_id
    #   destination_security_group_id = module.eks.node_security_group_id
    # }




    # # TODO Check if this helps with vault agent injector ops -- check if this really matters
    # ingress_allow_vault_inject_from_control_plane = {
    #   type                  = "ingress"
    #   protocol              = "tcp"
    #   from_port             = 8080
    #   to_port               = 8080
    #   source_security_group = module.eks.cluster_security_group_id
    # }

    # allow connections from ALB security group
    # ingress_allow_access_from_alb_sg = {
    #   type                     = "ingress"
    #   protocol                 = "-1"
    #   from_port                = 0
    #   to_port                  = 0
    #   source_security_group_id = var.aws_alb_security_group_id
    # }

    # allow connections from EKS to the internet
    egress_all = {
      protocol         = "-1"
      from_port        = 0
      to_port          = 0
      type             = "egress"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }

    # allow connections from EKS to EKS (internal calls)
    ingress_self_all = {
      protocol         = "-1"
      from_port        = 0
      to_port          = 0
      type             = "ingress"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
      # self      = true
    }
  }

  eks_managed_node_groups = {
    default = {
      ami_type       = "BOTTLEROCKET_x86_64"
      instance_types = ["t3.medium"]
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
        EC2 = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
        # Alb2 = "arn:aws:iam::aws:policy/AWSLoadBalancerControllerIAMPolicy"
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
