generate "provider_local_helm_k8s" {
  path      = "provider.local-helm-k8s.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<-EOF
    provider "kubernetes" {
      config_path = "~/.kube/config"
    }

    provider "helm" {
      kubernetes {
        config_path = "~/.kube/config"
      }
    }
  EOF
}
