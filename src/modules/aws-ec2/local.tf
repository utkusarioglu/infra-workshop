locals {
  ssh_private_key_abspath = join("/", [var.abspath_artifacts_base, "private-key.pem"])
  bucket_name             = "infra-workshop-aws-dev-s3-bucket"
  subdomain               = "meowz"
  email_address           = "utkusarioglu@hotmail.com"
}
