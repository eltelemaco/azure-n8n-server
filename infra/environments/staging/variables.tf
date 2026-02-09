# -----------------------------------------------------------------------------
# variables.tf - Staging Environment Input Variables
# -----------------------------------------------------------------------------
# Purpose: Declares all input variables for the staging environment.
# Staging mirrors production configuration with potentially reduced capacity.
#
# Conventions:
#   - All variables use snake_case naming
#   - Every variable includes a description
#   - Use validation blocks for constrained values
#   - Sensitive variables marked with sensitive = true
#   - Defaults reflect staging-appropriate values
#
# Next steps:
#   - Align variables with production as staging should mirror prod topology
#   - Add validation rules for all constrained variables
#   - Coordinate address spaces to avoid overlap with dev/production
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
  default     = ["10.2.0.0/16"]
}

variable "spoke_vnet_address_space" {
  description = "Address space for the spoke virtual network in CIDR notation"
  type        = list(string)
  default     = ["10.3.0.0/16"]
}

# --- Compute Configuration --------------------------------------------------

variable "vm_size" {
  description = "Azure VM size (SKU) for compute instances"
  type        = string
  default     = "Standard_D2s_v3"
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
  description = "Number of VM instances to deploy in the staging environment"
  type        = number
  default     = 2

  validation {
    condition     = var.vm_instance_count >= 1 && var.vm_instance_count <= 10
    error_message = "VM instance count must be between 1 and 10 for staging environment."
  }
}

# --- Security Configuration -------------------------------------------------

variable "enable_bastion" {
  description = "Enable Azure Bastion for secure VM access (no public IPs)"
  type        = bool
  default     = true
}

variable "enable_key_vault" {
  description = "Enable Azure Key Vault for secrets management"
  type        = bool
  default     = true
}

variable "enable_monitoring" {
  description = "Enable Azure Monitor and Log Analytics workspace"
  type        = bool
  default     = true
}

# --- Governance Configuration ------------------------------------------------

variable "enable_policy_assignments" {
  description = "Enable Azure Policy assignments for compliance enforcement"
  type        = bool
  default     = true
}

# --- Tags --------------------------------------------------------------------

variable "extra_tags" {
  description = "Additional custom tags to merge with common tags on all resources"
  type        = map(string)
  default     = {}
}
