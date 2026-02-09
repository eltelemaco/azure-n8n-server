# -----------------------------------------------------------------------------
# variables.tf - Networking Module Input Variables
# -----------------------------------------------------------------------------
# Purpose: Declares input variables for the networking module including
# VNet address spaces, subnet prefixes, and feature toggles.
#
# Conventions:
#   - All variables use snake_case naming
#   - Address spaces use CIDR notation
#   - Validation ensures non-overlapping address spaces
#
# Next steps:
#   - Add variables for route table configuration
#   - Add variables for DNS settings
#   - Add variables for VPN/ExpressRoute gateway configuration
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
  description = "Name of the resource group for networking resources"
  type        = string
}

# --- Hub VNet Configuration --------------------------------------------------

variable "hub_vnet_address_space" {
  description = "Address space for the hub virtual network in CIDR notation"
  type        = list(string)
}

variable "mgmt_subnet_prefix" {
  description = "Address prefix for the management subnet in the hub VNet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "bastion_subnet_prefix" {
  description = "Address prefix for the Azure Bastion subnet (minimum /26)"
  type        = string
  default     = "10.0.2.0/26"
}

# --- Spoke VNet Configuration -----------------------------------------------

variable "spoke_vnet_address_space" {
  description = "Address space for the spoke virtual network in CIDR notation"
  type        = list(string)
}

variable "web_subnet_prefix" {
  description = "Address prefix for the web tier subnet in the spoke VNet"
  type        = string
  default     = "10.1.1.0/24"
}

variable "app_subnet_prefix" {
  description = "Address prefix for the application tier subnet in the spoke VNet"
  type        = string
  default     = "10.1.2.0/24"
}

variable "data_subnet_prefix" {
  description = "Address prefix for the data tier subnet in the spoke VNet"
  type        = string
  default     = "10.1.3.0/24"
}

# --- Feature Toggles --------------------------------------------------------

variable "enable_bastion" {
  description = "Enable Azure Bastion for secure VM access"
  type        = bool
  default     = true
}

variable "enable_vnet_peering" {
  description = "Enable VNet peering between hub and spoke networks"
  type        = bool
  default     = true
}

# --- Tags --------------------------------------------------------------------

variable "tags" {
  description = "Map of tags to apply to all networking resources"
  type        = map(string)
  default     = {}
}
