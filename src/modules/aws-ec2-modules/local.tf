locals {
  ssh_private_key_abspath = join("/", [var.abspath_artifacts_base, "private-key.pem"])
}
