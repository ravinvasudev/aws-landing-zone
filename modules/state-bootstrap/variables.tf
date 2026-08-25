# ------------------------------------------------------------------------------
# State Bootstrap Module - Variables
# ------------------------------------------------------------------------------

variable "state_bucket_name" {
  description = "Name of the S3 bucket for Terraform state storage. Must be globally unique."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9.-]{1,61}[a-z0-9]$", var.state_bucket_name))
    error_message = "Bucket name must be 3-63 characters, lowercase letters, numbers, hyphens, and periods only."
  }
}

variable "lock_table_name" {
  description = "Name of the DynamoDB table for state locking."
  type        = string
  default     = "terraform-state-lock"

  validation {
    condition     = can(regex("^[a-zA-Z0-9_.-]{3,255}$", var.lock_table_name))
    error_message = "Table name must be 3-255 characters, alphanumeric, underscores, hyphens, and periods only."
  }
}

variable "kms_key_arn" {
  description = "ARN of KMS key for encryption. If null, uses AES256 (SSE-S3)."
  type        = string
  default     = null

  validation {
    condition     = var.kms_key_arn == null || can(regex("^arn:aws:kms:", var.kms_key_arn))
    error_message = "Must be a valid KMS key ARN or null."
  }
}

variable "access_logging_bucket" {
  description = "S3 bucket name for access logging. If null, logging is disabled."
  type        = string
  default     = null
}

variable "create_iam_policy" {
  description = "Whether to create an IAM policy for state access."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to apply to all resources."
  type        = map(string)
  default     = {}
}
