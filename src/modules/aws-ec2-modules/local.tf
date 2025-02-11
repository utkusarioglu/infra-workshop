locals {
  ssh_private_key_abspath = join("/", [var.abspath_artifacts_base, "private-key.pem"])
  subdomain               = "meow"
  bucket                  = "utkusarioglu-private-bucket-cat-dog"
}
