module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name                 = "cat"
  cidr                 = var.cidr_block
  azs                  = [var.availability_zone]
  public_subnets       = cidrsubnets(var.cidr_block, 1)
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags                 = var.tags
}

module "http" {
  source = "terraform-aws-modules/security-group/aws//modules/http-80"

  name                = "http80"
  description         = "Insecure HTTP access SG"
  vpc_id              = module.vpc.vpc_id
  ingress_cidr_blocks = ["0.0.0.0/0"]
  tags                = var.tags
}

module "https" {
  source = "terraform-aws-modules/security-group/aws//modules/https-443"

  name                = "http443"
  description         = "Secure HTTP access SG"
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

module "ec2_instance" {
  source = "terraform-aws-modules/ec2-instance/aws"

  create_spot_instance = true
  spot_price           = "0.003"
  spot_type            = "persistent"
  name                 = "dog"
  instance_type        = var.instance_type
  user_data = templatefile("user-data.sh", {
    bucket_id     = local.bucket_id
    email_address = "utkusarioglu@hotmail.com"
    domain_name   = module.acm.distinct_domain_names[0]
  })
  monitoring                  = true
  associate_public_ip_address = true
  spot_wait_for_fulfillment   = true
  subnet_id                   = module.vpc.public_subnets[0]
  key_name                    = module.key_pair.key_pair_name
  vpc_security_group_ids = [
    module.http.security_group_id,
    module.https.security_group_id,
    module.ssh.security_group_id
  ]

  create_iam_instance_profile = true
  iam_role_policies = {
    ReadS3 = module.iam_policy.arn
  }
  # ami       = data.aws_ami.ec2.id

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


module "records" {
  source  = "terraform-aws-modules/route53/aws//modules/records"
  version = "~> 3.0"

  zone_name = "utkusarioglu.com."

  records = [
    {
      name    = local.subdomain
      type    = "A"
      ttl     = 3600
      records = [module.ec2_instance.public_ip]
    },
  ]
}

module "s3_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = local.bucket_id
  acl    = "private"

  control_object_ownership = true
  object_ownership         = "ObjectWriter"

  versioning = {
    enabled = false
  }
  tags = var.tags
}

module "static_objects" {
  source = "terraform-aws-modules/s3-bucket/aws//modules/object"

  for_each    = fileset(local.abspath_assets_page_static, "*")
  bucket      = module.s3_bucket.s3_bucket_id
  key         = each.key
  file_source = join("/", [local.abspath_assets_page_static, each.key])
  tags        = var.tags
}

module "iam_policy" {
  source = "terraform-aws-modules/iam/aws//modules/iam-policy"

  name        = "S3read"
  path        = "/"
  description = "S3 read policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["s3:GetObject"]
      Resource = "arn:aws:s3:::${local.bucket_id}/*"
    }]
  })
  tags = var.tags
}

data "aws_route53_zone" "this" {
  name = "utkusarioglu.com."
}

module "acm" {
  source = "terraform-aws-modules/acm/aws"

  domain_name       = "${local.subdomain}.utkusarioglu.com"
  zone_id           = data.aws_route53_zone.this.zone_id
  validation_method = "DNS"

  wait_for_validation = true
}
