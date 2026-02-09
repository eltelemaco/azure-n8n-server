# -----------------------------------------------------------------------------
# variables.tf - Governance Module Input Variables
# -----------------------------------------------------------------------------
# Purpose: Declares input variables for the governance module including
# policy configuration, management group settings, and budget parameters.
#
# Conventions:
#   - All variables use snake_case naming
#   - Policy effects default to "audit" in non-production, "deny" in production
#   - Budget amounts are environment-specific
#
# Next steps:
#   - Add variables for additional policy definitions
#   - Add variables for policy exemption configuration
#   - Add variables for management group hierarchy customization
# -----------------------------------------------------------------------------

variable "environment" {
  description = "Environment name (dev, staging, production)"
  type        = string

  validation {
    condition     = contains(["dev", "staging", "production"], var.environment)
    error_message = "Environment must be dev, staging, or production."
  }
}

variable "organization_name" {
  description = "Organization name for management group hierarchy"
  type        = string
  default     = "azure-landing-zone"
}

# --- Policy Configuration ---------------------------------------------------

variable "enable_policy_assignments" {
  description = "Enable Azure Policy assignments for compliance enforcement"
  type        = bool
  default     = true
}

variable "required_tags" {
  description = "List of tag keys that must be present on all resources"
  type        = list(string)
  default     = ["environment", "managed_by", "project"]
}

# --- Budget Configuration ---------------------------------------------------

variable "enable_budget_alerts" {
  description = "Enable Azure budget alerts for cost governance"
  type        = bool
  default     = false
}

variable "monthly_budget_amount" {
  description = "Monthly budget amount in the subscription currency"
  type        = number
  default     = 1000

  validation {
    condition     = var.monthly_budget_amount > 0
    error_message = "Monthly budget amount must be greater than 0."
  }
}

variable "budget_start_date" {
  description = "Budget period start date in YYYY-MM-DD format (first of month)"
  type        = string
  default     = "2025-01-01"
}

variable "budget_alert_emails" {
  description = "Email addresses to receive budget alerts"
  type        = list(string)
  default     = []
}

# --- Tags --------------------------------------------------------------------

variable "tags" {
  description = "Map of tags to apply to governance resources"
  type        = map(string)
  default     = {}
}
