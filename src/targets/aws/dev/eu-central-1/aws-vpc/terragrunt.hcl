include "provider_aws" {
  path = find_in_parent_folders("provider.aws.hcl")
}

include "remote_state" {
  path = find_in_parent_folders("remote-state.hcl")
}

include "target" {
  path = find_in_parent_folders("target.hcl")
}

locals {
  vars = read_terragrunt_config(find_in_parent_folders("vars.hcl")).locals.vars
}

terraform {
  source = "tfr:///terraform-aws-modules/vpc/aws?version=5.17.0"
}

# Configure the inputs for the module
inputs = {
  name = "my-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = false
  enable_vpn_gateway = false

  tags = {
    IaC         = "true"
    Environment = "dev"
  }
}
