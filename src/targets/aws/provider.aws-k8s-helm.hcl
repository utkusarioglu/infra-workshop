locals {
  inputs = read_terragrunt_config(find_in_parent_folders("vars.hcl")).inputs
}

generate "provider_aws_helm_k8s" {
  path      = "provider.aws-helm-k8s.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<-EOF
    data "aws_eks_cluster_auth" "cluster" {
      name = "${local.inputs.names.cluster}"
    }

    data "aws_eks_cluster" "cluster" {
      name = "${local.inputs.names.cluster}"
    }

    provider "kubernetes" {
      host                   = data.aws_eks_cluster.cluster.endpoint
      cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
      token                  = data.aws_eks_cluster_auth.cluster.token
    }

    provider "helm" {
      kubernetes {
        host                   = data.aws_eks_cluster.cluster.endpoint
        cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
        token                  = data.aws_eks_cluster_auth.cluster.token
      }
    }
  EOF
}
