variable "cluster_name" {
  type = string
}

variable "region" {
  type = string
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
