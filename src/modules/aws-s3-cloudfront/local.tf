locals {
  index_html           = "index.html"
  error_html           = "error.html"
  fqdn                 = join(".", [var.dns.subdomain, var.dns.domain_name])
  label_assets_abspath = join("/", [var.assets_abspath, var.dns.subdomain])
}
