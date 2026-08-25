# ------------------------------------------------------------------------------
# State Bootstrap Module - Outputs
# ------------------------------------------------------------------------------

output "state_bucket_name" {
  description = "Name of the S3 bucket for Terraform state"
  value       = aws_s3_bucket.state.id
}

output "state_bucket_arn" {
  description = "ARN of the S3 bucket for Terraform state"
  value       = aws_s3_bucket.state.arn
}

output "state_bucket_region" {
  description = "Region of the S3 bucket"
  value       = aws_s3_bucket.state.region
}

output "lock_table_name" {
  description = "Name of the DynamoDB lock table"
  value       = aws_dynamodb_table.lock.name
}

output "lock_table_arn" {
  description = "ARN of the DynamoDB lock table"
  value       = aws_dynamodb_table.lock.arn
}

output "state_access_policy_arn" {
  description = "ARN of the IAM policy for state access (if created)"
  value       = var.create_iam_policy ? aws_iam_policy.state_access[0].arn : null
}

output "backend_config" {
  description = "Backend configuration block for use in root modules"
  value = {
    bucket         = aws_s3_bucket.state.id
    region         = aws_s3_bucket.state.region
    dynamodb_table = aws_dynamodb_table.lock.name
    encrypt        = true
  }
}

output "backend_config_hcl" {
  description = "Backend configuration as HCL string (for documentation)"
  value       = <<-EOT
    backend "s3" {
      bucket         = "${aws_s3_bucket.state.id}"
      key            = "ENVIRONMENT_NAME/terraform.tfstate"  # Update per environment
      region         = "${aws_s3_bucket.state.region}"
      dynamodb_table = "${aws_dynamodb_table.lock.name}"
      encrypt        = true
    }
  EOT
}
