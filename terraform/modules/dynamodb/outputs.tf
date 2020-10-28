
output "this_dynamodb_table_arn" {
  description = "ARN of the DynamoDB table"
  value       = aws_dynamodb_table.basic-dynamodb-table.arn
}

output "this_dynamodb_table_id" {
  description = "ID of the DynamoDB table"
  value       = aws_dynamodb_table.basic-dynamodb-table.id
}

output "this_dynamodb_table_stream_arn" {
  description = "The ARN of the Table Stream. Only available when var.stream_enabled is true"
  value       = aws_dynamodb_table.basic-dynamodb-table.stream_arn
}

output "this_dynamodb_table_stream_label" {
  description = "A timestamp, in ISO 8601 format of the Table Stream. Only available when var.stream_enabled is true"
  value       = aws_dynamodb_table.basic-dynamodb-table.stream_label
}
