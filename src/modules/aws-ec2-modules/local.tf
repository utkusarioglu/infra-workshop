locals {
  ssh_private_key_abspath = join("/", [var.abspath_artifacts_base, "private-key.pem"])
  subdomain               = "doc3"
  bucket_id               = "utkusarioglu-private-bucket-cat-dog"

  abspath_assets_page_static = join("/", [var.abspath_assets_base, "page", "static"])
  abspath_assets_page_tpl    = join("/", [var.abspath_assets_base, "page", "tpl"])

}
