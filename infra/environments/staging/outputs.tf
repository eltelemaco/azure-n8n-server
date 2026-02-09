# -----------------------------------------------------------------------------
# outputs.tf - Staging Environment Output Values
# -----------------------------------------------------------------------------
# Purpose: Defines output values for the staging environment. Outputs expose
# important resource attributes for use by other configurations, CI/CD
# pipelines, or operational tooling.
#
# Conventions:
#   - All outputs include a description
#   - Sensitive outputs marked with sensitive = true
#   - Output names use snake_case
#
# Next steps:
#   - Uncomment outputs as modules are implemented
#   - Mirror production outputs for consistency
# -----------------------------------------------------------------------------

# --- Resource Group Outputs --------------------------------------------------

# TODO: Uncomment when resource group is created
# output "resource_group_name" {
#   description = "Name of the staging environment resource group"
#   value       = azurerm_resource_group.main.name
# }

# output "resource_group_id" {
#   description = "Resource ID of the staging environment resource group"
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
  value       = "staging"
}

output "location" {
  description = "The Azure region for this deployment"
  value       = var.location
}
