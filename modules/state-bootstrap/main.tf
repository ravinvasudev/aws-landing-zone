# ------------------------------------------------------------------------------
# State Bootstrap Module
# Creates S3 bucket and DynamoDB table for Terraform state management
# ------------------------------------------------------------------------------
#
# This module is intended for product teams to bootstrap their own state
# infrastructure. It should be applied once manually before other infrastructure
# can be deployed.
#
# Usage:
#   cd state-bootstrap
#   terraform init    # Uses local state initially
#   terraform apply   # Creates the S3 bucket and DynamoDB table
#   # Then migrate local state to S3 (optional but recommended)
#
# ------------------------------------------------------------------------------

# S3 bucket for storing Terraform state
resource "aws_s3_bucket" "state" {
  bucket = var.state_bucket_name

  # Prevent accidental deletion of state bucket
  lifecycle {
    prevent_destroy = true
  }

  tags = merge(var.tags, {
    Purpose = "terraform-state"
  })
}

# Enable versioning for state recovery
resource "aws_s3_bucket_versioning" "state" {
  bucket = aws_s3_bucket.state.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Enable server-side encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "state" {
  bucket = aws_s3_bucket.state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = var.kms_key_arn != null ? "aws:kms" : "AES256"
      kms_master_key_id = var.kms_key_arn
    }
    bucket_key_enabled = var.kms_key_arn != null
  }
}

# Block all public access
resource "aws_s3_bucket_public_access_block" "state" {
  bucket = aws_s3_bucket.state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Enforce SSL-only access
resource "aws_s3_bucket_policy" "state" {
  bucket = aws_s3_bucket.state.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "DenyInsecureTransport"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource = [
          aws_s3_bucket.state.arn,
          "${aws_s3_bucket.state.arn}/*"
        ]
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      },
      {
        Sid       = "DenyIncorrectEncryptionHeader"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:PutObject"
        Resource  = "${aws_s3_bucket.state.arn}/*"
        Condition = {
          StringNotEquals = {
            "s3:x-amz-server-side-encryption" = var.kms_key_arn != null ? "aws:kms" : "AES256"
          }
        }
      }
    ]
  })
}

# Enable logging if log bucket is provided
resource "aws_s3_bucket_logging" "state" {
  count = var.access_logging_bucket != null ? 1 : 0

  bucket        = aws_s3_bucket.state.id
  target_bucket = var.access_logging_bucket
  target_prefix = "terraform-state-access-logs/${var.state_bucket_name}/"
}

# DynamoDB table for state locking
resource "aws_dynamodb_table" "lock" {
  name         = var.lock_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  # Enable point-in-time recovery
  point_in_time_recovery {
    enabled = true
  }

  # Enable server-side encryption
  server_side_encryption {
    enabled     = true
    kms_key_arn = var.kms_key_arn
  }

  tags = merge(var.tags, {
    Purpose = "terraform-state-lock"
  })

  lifecycle {
    prevent_destroy = true
  }
}

# IAM policy for state access (to be attached to pipeline roles)
resource "aws_iam_policy" "state_access" {
  count = var.create_iam_policy ? 1 : 0

  name        = "${var.state_bucket_name}-access"
  description = "Allows access to Terraform state bucket and lock table"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "S3StateAccess"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.state.arn,
          "${aws_s3_bucket.state.arn}/*"
        ]
      },
      {
        Sid    = "DynamoDBLockAccess"
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:DeleteItem"
        ]
        Resource = aws_dynamodb_table.lock.arn
      }
    ]
  })

  tags = var.tags
}
