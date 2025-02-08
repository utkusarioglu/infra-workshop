module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name                 = "cat"
  cidr                 = var.cidr_block
  azs                  = [var.availability_zone]
  public_subnets       = [cidrsubnet(var.cidr_block, 2, 0)]
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags                 = var.tags
}

module "http_80" {
  source = "terraform-aws-modules/security-group/aws//modules/http-80"

  name                = "http80"
  description         = "Insecure HTTP access SG"
  vpc_id              = module.vpc.vpc_id
  ingress_cidr_blocks = ["0.0.0.0/0"]
  tags                = var.tags
}

module "ssh" {
  source = "terraform-aws-modules/security-group/aws//modules/ssh"

  name                = "ssh"
  description         = "SSH access SG"
  vpc_id              = module.vpc.vpc_id
  ingress_cidr_blocks = ["0.0.0.0/0"]
  tags                = var.tags
}

data "aws_ami" "ec2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

module "ec2_instance" {
  source = "terraform-aws-modules/ec2-instance/aws"

  create_spot_instance        = true
  spot_price                  = "0.003"
  spot_type                   = "persistent"
  name                        = "dog"
  instance_type               = var.instance_type
  user_data                   = file("provisioning.sh")
  monitoring                  = true
  associate_public_ip_address = true
  spot_wait_for_fulfillment   = true
  vpc_security_group_ids = [
    module.http_80.security_group_id,
    module.ssh.security_group_id
  ]
  subnet_id = module.vpc.public_subnets[0]
  key_name  = module.key_pair.key_pair_name
  ami       = data.aws_ami.ec2.id

  tags = var.tags
}

module "key_pair" {
  source = "terraform-aws-modules/key-pair/aws"

  key_name           = var.key_pair_name
  create_private_key = true
}

resource "local_file" "ssh_private_key" {
  filename = local.ssh_private_key_abspath
  content  = module.key_pair.private_key_pem
}

resource "null_resource" "ssh_private_key_permissions" {
  depends_on = [local_file.ssh_private_key]

  provisioner "local-exec" {
    command = "chmod 600 ${local.ssh_private_key_abspath}"
  }
}
