variable "bucket_name" {
  type = string
}

variable "dns" {
  type = object({
    domain_name = string
    subdomain   = string
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

variable "assets_abspath" {
  type = string
}
