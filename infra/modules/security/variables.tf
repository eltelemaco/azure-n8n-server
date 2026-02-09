# -----------------------------------------------------------------------------
# variables.tf - Security Module Input Variables
# -----------------------------------------------------------------------------
# Purpose: Declares input variables for the security module including
# Key Vault settings, policy configuration, and RBAC parameters.
#
# Conventions:
#   - All variables use snake_case naming
#   - Security-sensitive defaults favor restrictive settings
#   - Production enforces stricter configurations
#
# Next steps:
#   - Add variables for Azure Policy initiative selection
#   - Add variables for custom RBAC role definitions
#   - Add variables for Key Vault private endpoint configuration
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

variable "resource_group_name" {
  description = "Name of the resource group for security resources"
  type        = string
}

# --- Key Vault Configuration ------------------------------------------------

variable "enable_key_vault" {
  description = "Enable Azure Key Vault for secrets management"
  type        = bool
  default     = true
}

variable "key_vault_sku" {
  description = "SKU for the Azure Key Vault (standard or premium)"
  type        = string
  default     = "standard"

  validation {
    condition     = contains(["standard", "premium"], var.key_vault_sku)
    error_message = "Key Vault SKU must be standard or premium."
  }
}

variable "soft_delete_retention_days" {
  description = "Number of days to retain soft-deleted Key Vault items"
  type        = number
  default     = 90

  validation {
    condition     = var.soft_delete_retention_days >= 7 && var.soft_delete_retention_days <= 90
    error_message = "Soft delete retention must be between 7 and 90 days."
  }
}

# --- Monitoring Integration --------------------------------------------------

variable "log_analytics_workspace_id" {
  description = "Resource ID of the Log Analytics workspace for diagnostic settings"
  type        = string
  default     = ""
}

# --- Tags --------------------------------------------------------------------

variable "tags" {
  description = "Map of tags to apply to all security resources"
  type        = map(string)
  default     = {}
}
