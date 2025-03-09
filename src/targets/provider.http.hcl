generate "provider_http" {
  path      = "provider.http.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<-EOF
    provider "http" {
    }
  EOF
}
