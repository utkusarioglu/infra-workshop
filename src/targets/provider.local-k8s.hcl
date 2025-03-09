generate "provider_local_kubernetes" {
  path      = "provider.local-kubernetes.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<-EOF
    provider "kubernetes" {
      config_path = "~/.kube/config"
    }
  EOF
}
