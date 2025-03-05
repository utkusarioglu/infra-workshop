locals {
  inputs = read_terragrunt_config(find_in_parent_folders("vars.hcl")).inputs
}

generate "provider_helm" {
  path      = "provider.helm.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<-EOF
    provider "helm" {
      kubernetes {
        config_path = "~/.kube/config"
      }
    }
  EOF
}

# generate "required_provider_aws" {
#   path      = "required-provider.aws.tf"
#   if_exists = "overwrite_terragrunt"
#   contents  = <<-EOF
#     terraform {
#       required_providers {
#         aws = {
#           source = "hashicorp/aws"
#           version = "5.84.0"
#         }
#       }
#     }
#   EOF
# }
