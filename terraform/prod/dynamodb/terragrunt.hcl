locals {
 
 # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))

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
  app_env = "${local.app_env}"
  aws_region = "${local.aws_region}"
  
}