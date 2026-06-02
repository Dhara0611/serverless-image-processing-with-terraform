# ============================================================================
# AWS LAMBDA IMAGE PROCESSOR WITH COMPREHENSIVE MONITORING
# Modular Terraform Configuration
# ============================================================================

# Random suffix for unique resource names
resource "random_id" "suffix" {
  byte_length = 4
}

locals {
  bucket_prefix         = "${var.project_name}-${var.environment}"
  upload_bucket_name    = "${local.bucket_prefix}-upload-${random_id.suffix.hex}"
  processed_bucket_name = "${local.bucket_prefix}-processed-${random_id.suffix.hex}"
  lambda_function_name  = "${var.project_name}-${var.environment}-processor"

  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
    CreatedDate = timestamp()
  }
}

# ============================================================================
# LAMBDA LAYER (Pillow)
# ============================================================================

resource "aws_lambda_layer_version" "pillow_layer" {
  filename            = "${path.module}/pillow_layer.zip"
  layer_name          = "${var.project_name}-pillow-layer"
  compatible_runtimes = ["python3.12"]
  description         = "Pillow library for image processing"
}

# Data source for Lambda function zip
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/../lambda/lambda_function.py"
  output_path = "${path.module}/lambda_function.zip"
}

# ============================================================================
# MODULE: S3 BUCKETS (Created First)
# Creates upload and processed buckets with security configurations
# ============================================================================

module "s3_buckets" {
  source = "./modules/s3_buckets"

  upload_bucket_name    = local.upload_bucket_name.id
  processed_bucket_name = local.processed_bucket_name.id
  environment           = var.environment
  enable_versioning     = var.enable_s3_versioning

  tags = local.common_tags
}