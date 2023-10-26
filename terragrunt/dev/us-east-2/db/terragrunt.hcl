terraform {
  source = "../../../../modules/infrustructure-modules/db"
}

include "root" {
  path = find_in_parent_folders()
}

inputs = {
  security_group_id = dependency.vpc.outputs.security_group_id
  db_subnet_group_name = dependency.vpc.outputs.db_subnet_group_name
}

dependency "vpc" {
  config_path = "../network"

  mock_outputs = {
    security_group_id = "dfvdjv"
    db_subnet_group_name ="dfgdrhd"
  }
}