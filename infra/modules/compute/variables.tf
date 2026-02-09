# -----------------------------------------------------------------------------
# variables.tf - Compute Module Input Variables
# -----------------------------------------------------------------------------
# Purpose: Declares input variables for the compute module including VM
# sizing, image configuration, and security settings.
#
# Conventions:
#   - All variables use snake_case naming
#   - Sensitive variables (passwords) marked with sensitive = true
#   - VM sizes validated against known SKUs
#   - Image references use latest stable versions
#
# Next steps:
#   - Add variables for availability zone/set configuration
#   - Add variables for custom script extensions
#   - Add variables for data disk configuration
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
  description = "Name of the resource group for compute resources"
  type        = string
}

variable "subnet_id" {
  description = "Resource ID of the subnet for VM network interfaces"
  type        = string
}

# --- VM Configuration --------------------------------------------------------

variable "vm_name_prefix" {
  description = "Prefix for VM resource names (e.g., vm-dev-app)"
  type        = string
  default     = "vm-app"
}

variable "vm_size" {
  description = "Azure VM size (SKU) for compute instances"
  type        = string
  default     = "Standard_D2s_v3"
}

variable "vm_instance_count" {
  description = "Number of VM instances to deploy"
  type        = number
  default     = 1

  validation {
    condition     = var.vm_instance_count >= 1 && var.vm_instance_count <= 20
    error_message = "VM instance count must be between 1 and 20."
  }
}

variable "admin_username" {
  description = "Administrator username for VM instances"
  type        = string
  default     = "azureadmin"

  validation {
    condition     = !contains(["admin", "administrator", "root"], var.admin_username)
    error_message = "Admin username must not be 'admin', 'administrator', or 'root'."
  }
}

variable "admin_password" {
  description = "Administrator password for VM instances (from Key Vault)"
  type        = string
  sensitive   = true
  default     = ""
}

# --- OS Disk Configuration ---------------------------------------------------

variable "os_disk_caching" {
  description = "Caching type for the OS disk (None, ReadOnly, ReadWrite)"
  type        = string
  default     = "ReadWrite"

  validation {
    condition     = contains(["None", "ReadOnly", "ReadWrite"], var.os_disk_caching)
    error_message = "OS disk caching must be None, ReadOnly, or ReadWrite."
  }
}

variable "os_disk_type" {
  description = "Storage account type for the OS disk"
  type        = string
  default     = "Premium_LRS"

  validation {
    condition     = contains(["Standard_LRS", "StandardSSD_LRS", "Premium_LRS"], var.os_disk_type)
    error_message = "OS disk type must be Standard_LRS, StandardSSD_LRS, or Premium_LRS."
  }
}

# --- Image Configuration ----------------------------------------------------

variable "image_publisher" {
  description = "Publisher of the VM image"
  type        = string
  default     = "Canonical"
}

variable "image_offer" {
  description = "Offer of the VM image"
  type        = string
  default     = "0001-com-ubuntu-server-jammy"
}

variable "image_sku" {
  description = "SKU of the VM image"
  type        = string
  default     = "22_04-lts-gen2"
}

variable "image_version" {
  description = "Version of the VM image"
  type        = string
  default     = "latest"
}

# --- Identity Configuration --------------------------------------------------

variable "managed_identity_ids" {
  description = "List of user-assigned managed identity IDs to attach to VMs"
  type        = list(string)
  default     = []
}

# --- Monitoring Configuration ------------------------------------------------

variable "enable_monitoring" {
  description = "Enable Azure Monitor agent on VM instances"
  type        = bool
  default     = true
}

# --- Tags --------------------------------------------------------------------

variable "tags" {
  description = "Map of tags to apply to all compute resources"
  type        = map(string)
  default     = {}
}
