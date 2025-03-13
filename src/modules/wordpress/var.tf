variable "security_group_id" {
  type = string
}

variable "platform" {
  type = string
  validation {
    condition     = contains(["aws", "k3d"], var.platform)
    error_message = "Unrecognized platform: ${var.platform}"
  }
}

variable "aws_acm_certificate_arn" {
  type        = string
  description = "Aws requires a certificate attachment to the load balancer"
}

variable "dns" {
  type = object({
    base_domain = string
    subdomain   = string
    hostname    = string
  })
}

variable "annotations" {
  description = "Annotations given to each deployed Instance"
  # type        = any
  type = list(object({
    key   = string
    value = string
  }))
  # type = object({
  #   "tag.repo.utkusarioglu.com/cluster"       = string
  #   "tag.repo.utkusarioglu.com/cluster-short" = string
  #   "tag.repo.utkusarioglu.com/environment"   = string
  #   "tag.repo.utkusarioglu.com/label"         = string
  #   "tag.repo.utkusarioglu.com/platform"      = string
  #   "tag.repo.utkusarioglu.com/region"        = string
  #   "tag.repo.utkusarioglu.com/region-short"  = string
  #   "tag.repo.utkusarioglu.com/unit"          = string
  # })
}

# Cluster      = string
# ClusterShort = string
# Platform     = string
# Region       = string
# RegionShort  = string
# Environment  = string
# Unit         = string
