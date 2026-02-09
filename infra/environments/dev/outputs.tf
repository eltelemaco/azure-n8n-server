# -----------------------------------------------------------------------------
# outputs.tf - Dev Environment Output Values
# -----------------------------------------------------------------------------
# Purpose: Defines output values for the dev environment. Outputs expose
# important resource attributes (IDs, names, endpoints) for use by other
# configurations, CI/CD pipelines, or operational tooling.
#
# Conventions:
#   - All outputs include a description
#   - Sensitive outputs marked with sensitive = true
#   - Output names use snake_case
#   - Group outputs by module/resource type
#
# Next steps:
#   - Uncomment outputs as modules are implemented
#   - Add outputs for cross-environment references
#   - Ensure sensitive values (passwords, keys) are marked sensitive
# -----------------------------------------------------------------------------

# --- Resource Group Outputs --------------------------------------------------

# TODO: Uncomment when resource group is created
# output "resource_group_name" {
#   description = "Name of the dev environment resource group"
#   value       = azurerm_resource_group.main.name
# }

# output "resource_group_id" {
#   description = "Resource ID of the dev environment resource group"
#   value       = azurerm_resource_group.main.id
# }

# --- Networking Outputs ------------------------------------------------------

# TODO: Uncomment when networking module is implemented
# output "hub_vnet_id" {
#   description = "Resource ID of the hub virtual network"
#   value       = module.networking.hub_vnet_id
# }

# output "spoke_vnet_id" {
#   description = "Resource ID of the spoke virtual network"
#   value       = module.networking.spoke_vnet_id
# }

# output "subnet_ids" {
#   description = "Map of subnet names to their resource IDs"
#   value       = module.networking.subnet_ids
# }

# --- Security Outputs -------------------------------------------------------

# TODO: Uncomment when security module is implemented
# output "key_vault_id" {
#   description = "Resource ID of the Azure Key Vault"
#   value       = module.security.key_vault_id
# }

# output "key_vault_uri" {
#   description = "URI of the Azure Key Vault"
#   value       = module.security.key_vault_uri
# }

# --- Compute Outputs ---------------------------------------------------------

# TODO: Uncomment when compute module is implemented
# output "vm_ids" {
#   description = "List of VM resource IDs"
#   value       = module.compute.vm_ids
# }

# output "vm_private_ips" {
#   description = "List of VM private IP addresses"
#   value       = module.compute.vm_private_ips
# }

# output "vm_admin_password" {
#   description = "Generated admin password for VM instances (stored in Key Vault)"
#   value       = module.compute.admin_password
#   sensitive   = true
# }

# --- Environment Metadata ----------------------------------------------------

output "environment" {
  description = "The environment name for this deployment"
  value       = "dev"
}

output "location" {
  description = "The Azure region for this deployment"
  value       = var.location
}

output "tenant_id" {
  description = "Azure tenant ID for the current credentials"
  value       = data.azurerm_client_config.current.tenant_id
}

output "subscription_id" {
  description = "Azure subscription ID for the current credentials"
  value       = data.azurerm_client_config.current.subscription_id
}

output "resource_group_name" {
  description = "Target resource group name"
  value       = data.azurerm_resource_group.target.name
}

output "resource_group_id" {
  description = "Target resource group ID"
  value       = data.azurerm_resource_group.target.id
}

output "vnet_id" {
  description = "Target virtual network ID"
  value       = azurerm_virtual_network.main.id
}

output "subnet_ids" {
  description = "Map of subnet names to IDs"
  value       = { for name, subnet in data.azurerm_subnet.target : name => subnet.id }
}
