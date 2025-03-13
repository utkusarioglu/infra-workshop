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

variable "tags" {
  description = "Tag given to each deployed Instance"
  type = object({
    Cluster      = string
    ClusterShort = string
    Platform     = string
    Region       = string
    RegionShort  = string
    Environment  = string
    Unit         = string
  })
}
