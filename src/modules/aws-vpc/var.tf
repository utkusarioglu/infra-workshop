variable "cluster_code" {
  type = string
}

variable "tags" {
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
