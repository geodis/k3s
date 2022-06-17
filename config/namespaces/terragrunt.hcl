terraform {
  source = "${get_parent_terragrunt_dir()}../../infra//namespaces/"
}


include {
  path = find_in_parent_folders()
}


locals {
}

inputs = {
}
