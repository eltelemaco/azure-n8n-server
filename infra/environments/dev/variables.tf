# -----------------------------------------------------------------------------
# variables.tf - Dev Environment Input Variables
# -----------------------------------------------------------------------------
# Purpose: Declares all input variables for the dev environment configuration.
# Variable values are provided via terraform.tfvars or HCP Terraform workspace
# variable sets.
#
# Conventions:
#   - All variables use snake_case naming
#   - Every variable includes a description
#   - Use validation blocks for constrained values
#   - Sensitive variables marked with sensitive = true
#   - Default values provided where appropriate for dev environment
#
# Next steps:
#   - Add validation rules for all constrained variables
#   - Add variables for new modules as they are implemented
#   - Ensure terraform.tfvars.example stays in sync with this file
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
  default     = ["10.0.0.0/16"]
}

variable "spoke_vnet_address_space" {
  description = "Address space for the spoke virtual network in CIDR notation"
  type        = list(string)
  default     = ["10.1.0.0/16"]
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
  description = "Number of VM instances to deploy in the dev environment"
  type        = number
  default     = 1

  validation {
    condition     = var.vm_instance_count >= 1 && var.vm_instance_count <= 5
    error_message = "VM instance count must be between 1 and 5 for dev environment."
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

# --- Existing Azure Resources for Data Lookups ------------------------------

variable "resource_group_name" {
  description = "Existing resource group name used for data lookups."
  type        = string
  default     = "telemaco-dev"
}

variable "vnet_name" {
  description = "Existing virtual network name used for data lookups."
  type        = string
  default     = "value"
}

variable "subnet_names" {
  description = "Existing subnet names to look up within the virtual network."
  type        = list(string)
  default     = []
}
