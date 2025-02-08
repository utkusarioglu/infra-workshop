variable "key_pair_name" {
  description = "key_pair_name"
  type        = string
}

variable "instance_type" {
  description = "instance_type"
  type        = string
}

variable "abspath_artifacts_base" {
  description = "The path to which artifacts should be pushed"
  type        = string
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


# variable "counter" {
#   description = "Number of instances to launch"
#   type        = number
# }

# variable "file_name" {
#   description = "Name of the key pair"
#   type        = string
# }

variable "cidr_block" {
  description = "CIDR Block"
  type        = string
}

variable "availability_zone" {
  description = "Availability Zones for the Subnet"
  type        = string
}
