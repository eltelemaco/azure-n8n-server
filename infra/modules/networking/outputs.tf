# -----------------------------------------------------------------------------
# outputs.tf - Networking Module Output Values
# -----------------------------------------------------------------------------
# Purpose: Exports networking resource attributes for use by dependent
# modules (compute, security) and environment root configurations.
#
# Conventions:
#   - All outputs include a description
#   - Output names use snake_case
#   - Subnet IDs exposed as a map for flexible access
#
# Next steps:
#   - Uncomment outputs as resources are implemented
#   - Add outputs for NSG IDs
#   - Add outputs for Bastion host FQDN
# -----------------------------------------------------------------------------

# --- Hub VNet Outputs --------------------------------------------------------

# TODO: Uncomment when hub VNet is created
# output "hub_vnet_id" {
#   description = "Resource ID of the hub virtual network"
#   value       = azurerm_virtual_network.hub.id
# }

# output "hub_vnet_name" {
#   description = "Name of the hub virtual network"
#   value       = azurerm_virtual_network.hub.name
# }

# --- Spoke VNet Outputs ------------------------------------------------------

# TODO: Uncomment when spoke VNet is created
# output "spoke_vnet_id" {
#   description = "Resource ID of the spoke virtual network"
#   value       = azurerm_virtual_network.spoke.id
# }

# output "spoke_vnet_name" {
#   description = "Name of the spoke virtual network"
#   value       = azurerm_virtual_network.spoke.name
# }

# --- Subnet Outputs ----------------------------------------------------------

# TODO: Uncomment when subnets are created
# output "subnet_ids" {
#   description = "Map of subnet names to their resource IDs"
#   value = {
#     mgmt = azurerm_subnet.mgmt.id
#     web  = azurerm_subnet.web.id
#     app  = azurerm_subnet.app.id
#     data = azurerm_subnet.data.id
#   }
# }

# --- NSG Outputs -------------------------------------------------------------

# TODO: Uncomment when NSGs are created
# output "app_nsg_id" {
#   description = "Resource ID of the application subnet NSG"
#   value       = azurerm_network_security_group.app.id
# }

# --- Bastion Outputs ---------------------------------------------------------

# TODO: Uncomment when Bastion is created
# output "bastion_host_id" {
#   description = "Resource ID of the Azure Bastion host"
#   value       = var.enable_bastion ? azurerm_bastion_host.main[0].id : null
# }
