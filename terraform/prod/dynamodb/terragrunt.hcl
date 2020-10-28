locals {
 
 # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))

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
  aws_region = "us-east-2"
  table_name = "Weather"
  hash_key = "zip"
  hash_key_type = "S"
  range_key = "temp"
  range_key_type = "N"
  
}