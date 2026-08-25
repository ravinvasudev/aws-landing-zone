# ------------------------------------------------------------------------------
# FinOps Budgets Module - Variables
# ------------------------------------------------------------------------------

variable "budget_name" {
  description = "Name for the budget"
  type        = string

  validation {
    condition     = length(var.budget_name) >= 3 && length(var.budget_name) <= 100
    error_message = "Budget name must be between 3 and 100 characters."
  }
}

variable "budget_limit_amount" {
  description = "Monthly budget limit in USD"
  type        = number

  validation {
    condition     = var.budget_limit_amount > 0
    error_message = "Budget limit must be greater than 0."
  }
}

variable "budget_type" {
  description = "Type of budget (COST, USAGE, RI_UTILIZATION, RI_COVERAGE, SAVINGS_PLANS_UTILIZATION, SAVINGS_PLANS_COVERAGE)"
  type        = string
  default     = "COST"

  validation {
    condition     = contains(["COST", "USAGE", "RI_UTILIZATION", "RI_COVERAGE", "SAVINGS_PLANS_UTILIZATION", "SAVINGS_PLANS_COVERAGE"], var.budget_type)
    error_message = "Invalid budget type."
  }
}

variable "alert_thresholds" {
  description = "List of percentage thresholds that trigger alerts (e.g., [50, 80, 100, 120])"
  type        = list(number)
  default     = [50, 80, 100, 120]

  validation {
    condition     = length(var.alert_thresholds) > 0
    error_message = "At least one alert threshold must be specified."
  }
}

variable "alert_email_addresses" {
  description = "Email addresses to notify when thresholds are breached"
  type        = list(string)
  default     = []
}

variable "cost_filters" {
  description = "Cost filters to scope the budget (e.g., by tag, service, or linked account)"
  type        = map(list(string))
  default     = {}
}

variable "enable_anomaly_detection" {
  description = "Whether to enable AWS Cost Anomaly Detection"
  type        = bool
  default     = true
}

variable "anomaly_monitor_type" {
  description = "Type of anomaly monitor (DIMENSIONAL or CUSTOM)"
  type        = string
  default     = "DIMENSIONAL"
}

variable "anomaly_threshold_percentage" {
  description = "Percentage threshold for anomaly alerts"
  type        = number
  default     = 10
}

variable "tags" {
  description = "Tags to apply to budget resources"
  type        = map(string)
  default     = {}
}
