# ============================================================================
# S3 BUCKET OUTPUTS
# ============================================================================

output "upload_bucket_name" {
  description = "S3 bucket for uploading images (SOURCE)"
  value       = module.s3_buckets.upload_bucket_id
}

output "processed_bucket_name" {
  description = "S3 bucket for processed images (DESTINATION)"
  value       = module.s3_buckets.processed_bucket_id
}

output "upload_bucket_arn" {
  description = "ARN of the upload bucket"
  value       = module.s3_buckets.upload_bucket_arn
}

output "processed_bucket_arn" {
  description = "ARN of the processed bucket"
  value       = module.s3_buckets.processed_bucket_arn
}

# ============================================================================
# LAMBDA FUNCTION OUTPUTS
# ============================================================================

output "lambda_function_name" {
  description = "Name of the Lambda function"
  value       = module.lambda_function.function_name
}

output "lambda_function_arn" {
  description = "ARN of the Lambda function"
  value       = module.lambda_function.function_arn
}
output "lambda_log_group_name" {
  description = "CloudWatch Log Group name for Lambda"
  value       = module.lambda_function.log_group_name
}