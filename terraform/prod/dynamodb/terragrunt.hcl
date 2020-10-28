locals {
 
 # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  aws_region = local.region_vars.locals.aws_region

  # Extract out common variables for reuse
  env = local.environment_vars.locals.environment
}


# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

terraform {
  # Deploy version v0.0.3 in stage
  source = "../../modules/dynamodb"
  
  }

inputs = {
  env = local.env
  table_name = "Weather"
  hash_key = "zip"
  hash_key_type = "S"
  range_key = "temp"
  range_key_type = "N"
  
}