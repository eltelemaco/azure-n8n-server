# -----------------------------------------------------------------------------
# variables.tf - Production Environment Input Variables
# -----------------------------------------------------------------------------
# Purpose: Declares all input variables for the production environment.
# Production values emphasize high availability, security, and compliance.
#
# Conventions:
#   - All variables use snake_case naming
#   - Every variable includes a description
#   - Strict validation blocks for production constraints
#   - Sensitive variables marked with sensitive = true
#   - No unsafe defaults - critical values must be explicitly set
#
# Next steps:
#   - Add stricter validation rules for production constraints
#   - Coordinate with security team for compliance requirements
#   - Review VM sizes for production SLA requirements
# -----------------------------------------------------------------------------

# --- General Configuration ---------------------------------------------------

variable "location" {
  description = "Primary Azure region for resource deployment"
  type        = string
  default     = "eastus"
}

variable "project_name" {
  description = "Project name used in resource naming and tagging"
  type        = string
  default     = "azure-landing-zone"
}

variable "owner" {
  description = "Resource owner for tagging and accountability"
  type        = string
  default     = "team-infrastructure"
}

variable "cost_center" {
  description = "Cost center identifier for billing allocation"
  type        = string
  default     = "IT-001"
}

# --- Networking Configuration ------------------------------------------------

variable "hub_vnet_address_space" {
  description = "Address space for the hub virtual network in CIDR notation"
  type        = list(string)
  default     = ["10.4.0.0/16"]
}

variable "spoke_vnet_address_space" {
  description = "Address space for the spoke virtual network in CIDR notation"
  type        = list(string)
  default     = ["10.5.0.0/16"]
}

# --- Compute Configuration --------------------------------------------------

variable "vm_size" {
  description = "Azure VM size (SKU) for compute instances - use production-grade sizes"
  type        = string
  default     = "Standard_D4s_v3"
}

variable "admin_username" {
  description = "Administrator username for VM instances (avoid 'admin' or 'administrator')"
  type        = string
  default     = "azureadmin"

  validation {
    condition     = !contains(["admin", "administrator", "root"], var.admin_username)
    error_message = "Admin username must not be 'admin', 'administrator', or 'root'."
  }
}

variable "vm_instance_count" {
  description = "Number of VM instances to deploy in production (minimum 2 for HA)"
  type        = number
  default     = 3

  validation {
    condition     = var.vm_instance_count >= 2 && var.vm_instance_count <= 20
    error_message = "Production VM instance count must be between 2 and 20 for high availability."
  }
}

# --- Security Configuration -------------------------------------------------

variable "enable_bastion" {
  description = "Enable Azure Bastion for secure VM access (required in production)"
  type        = bool
  default     = true

  validation {
    condition     = var.enable_bastion == true
    error_message = "Azure Bastion must be enabled in production for secure access."
  }
}

variable "enable_key_vault" {
  description = "Enable Azure Key Vault for secrets management (required in production)"
  type        = bool
  default     = true

  validation {
    condition     = var.enable_key_vault == true
    error_message = "Azure Key Vault must be enabled in production for secrets management."
  }
}

variable "enable_monitoring" {
  description = "Enable Azure Monitor and Log Analytics (required in production)"
  type        = bool
  default     = true

  validation {
    condition     = var.enable_monitoring == true
    error_message = "Azure Monitor must be enabled in production for observability."
  }
}

# --- Governance Configuration ------------------------------------------------

variable "enable_policy_assignments" {
  description = "Enable Azure Policy assignments (required in production)"
  type        = bool
  default     = true

  validation {
    condition     = var.enable_policy_assignments == true
    error_message = "Azure Policy assignments must be enabled in production for compliance."
  }
}

# --- Tags --------------------------------------------------------------------

variable "extra_tags" {
  description = "Additional custom tags to merge with common tags on all resources"
  type        = map(string)
  default     = {}
}
