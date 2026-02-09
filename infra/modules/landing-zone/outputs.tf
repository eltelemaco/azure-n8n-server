# -----------------------------------------------------------------------------
# outputs.tf - Landing Zone Module Output Values
# -----------------------------------------------------------------------------
# Purpose: Exports resource attributes from the landing zone module for use
# by dependent modules and environment root configurations.
#
# Conventions:
#   - All outputs include a description
#   - Sensitive outputs marked with sensitive = true
#   - Output names use snake_case
#   - Version all outputs to enable dependent modules
#
# Next steps:
#   - Uncomment outputs as resources are implemented
#   - Add outputs for Log Analytics workspace ID and key
#   - Add outputs for action group IDs
# -----------------------------------------------------------------------------

# --- Resource Group Outputs --------------------------------------------------

# TODO: Uncomment when resource group is created
# output "resource_group_name" {
#   description = "Name of the landing zone resource group"
#   value       = azurerm_resource_group.landing_zone.name
# }

# output "resource_group_id" {
#   description = "Resource ID of the landing zone resource group"
#   value       = azurerm_resource_group.landing_zone.id
# }

# output "resource_group_location" {
#   description = "Location of the landing zone resource group"
#   value       = azurerm_resource_group.landing_zone.location
# }

# --- Log Analytics Outputs ---------------------------------------------------

# TODO: Uncomment when Log Analytics workspace is created
# output "log_analytics_workspace_id" {
#   description = "Resource ID of the Log Analytics workspace"
#   value       = azurerm_log_analytics_workspace.main.id
# }

# output "log_analytics_workspace_name" {
#   description = "Name of the Log Analytics workspace"
#   value       = azurerm_log_analytics_workspace.main.name
# }

# output "log_analytics_primary_key" {
#   description = "Primary shared key for the Log Analytics workspace"
#   value       = azurerm_log_analytics_workspace.main.primary_shared_key
#   sensitive   = true
# }

# --- Monitor Outputs ---------------------------------------------------------

# TODO: Uncomment when action groups are created
# output "critical_action_group_id" {
#   description = "Resource ID of the critical alerts action group"
#   value       = azurerm_monitor_action_group.critical.id
# }
