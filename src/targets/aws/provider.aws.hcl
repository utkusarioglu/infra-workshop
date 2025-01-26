locals {
  vars = read_terragrunt_config(find_in_parent_folders("vars.hcl")).locals.vars
}

generate "provider_aws" {
  path      = "provider.aws.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<-EOF
    provider "aws" {
      region = "${local.vars.names.region}"
      profile = "${local.vars.profile}"
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
