include "remote_state" {
  path = find_in_parent_folders("remote-state.hcl")
}

include "target" {
  path = find_in_parent_folders("target.hcl")
}

# include "platform" {
#   path = find_in_parent_folders("platform.hcl")
# }
