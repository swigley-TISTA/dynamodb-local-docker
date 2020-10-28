

variable "table_name" {
  type = string
  description = "The name for the dynamoDB table."
}

variable "hash_key" {
  type = string
  description = "The name of the hash key for the dynamoDB table."
}

variable "hash_key_type" {
  type = string
  description = "The type of the hash key for the dynamoDB table."
}

variable "range_key" {
  type = string
  description = "The name of the range key for the dynamoDB table."
}

variable "range_key_type" {
  type = string
  description = "The type of the range key for the dynamoDB table."
}
variable "env" {
  type = string
  description = "The name of the environment for the dynamoDB table (prod, dev, qa, etc.)."
}

variable "aws_region" {
  type = string
  description = "The name of the aws_region for the dynamoDB table."
}

provider "aws" {
  region = var.aws_region
}


resource "aws_dynamodb_table" "basic-dynamodb-table" {
  name           = "${var.table_name}-${var.env}"
  billing_mode   = "PROVISIONED"
  read_capacity  = 20
  write_capacity = 20
  hash_key       = var.hash_key
  range_key      = var.range_key

  attribute {
    name = var.hash_key
    type = "S"
  }

  attribute {
    name = var.range_key
    type = "N"
  }

  ttl {
    attribute_name = "TimeToExist"
    enabled        = false
  }

  tags = {
    Name        = var.table_name
    Environment = var.env
  }
}