# -----------------------------------------------------------------------------
# variables.tf - Landing Zone Module Input Variables
# -----------------------------------------------------------------------------
# Purpose: Declares input variables for the landing zone core module.
# These variables control the foundational infrastructure configuration.
#
# Conventions:
#   - All variables use snake_case naming
#   - Every variable includes a description and type
#   - Validation blocks enforce constraints
#   - Sensitive variables marked appropriately
#
# Next steps:
#   - Add variables for Log Analytics configuration
#   - Add variables for alert notification recipients
#   - Add variables for diagnostic setting categories
# -----------------------------------------------------------------------------

variable "environment" {
  description = "Environment name (dev, staging, production)"
  type        = string

  validation {
    condition     = contains(["dev", "staging", "production"], var.environment)
    error_message = "Environment must be dev, staging, or production."
  }
}

variable "location" {
  description = "Azure region for resource deployment"
  type        = string
}

variable "landing_zone_name" {
  description = "Name suffix for the landing zone resources"
  type        = string
  default     = "landing-zone"
}

variable "resource_group_name" {
  description = "Name of the resource group (if using an existing one)"
  type        = string
  default     = ""
}

variable "log_retention_days" {
  description = "Number of days to retain logs in Log Analytics workspace"
  type        = number
  default     = 30

  validation {
    condition     = var.log_retention_days >= 30 && var.log_retention_days <= 730
    error_message = "Log retention must be between 30 and 730 days."
  }
}

variable "tags" {
  description = "Map of tags to apply to all resources in this module"
  type        = map(string)
  default     = {}
}
