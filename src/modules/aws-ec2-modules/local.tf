locals {
  ssh_private_key_abspath = join("/", [var.abspath_artifacts_base, "private-key.pem"])
  subdomain               = "catz"
  bucket                  = "utkusarioglu-private-bucket-cat-dog"
}
