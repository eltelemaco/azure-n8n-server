# -----------------------------------------------------------------------------
# outputs.tf - Governance Module Output Values
# -----------------------------------------------------------------------------
# Purpose: Exports governance resource attributes including management group
# IDs, policy assignment IDs, and budget configuration for reference.
#
# Conventions:
#   - All outputs include a description
#   - Output names use snake_case
#
# Next steps:
#   - Uncomment outputs as resources are implemented
#   - Add outputs for policy compliance state
#   - Add outputs for management group hierarchy
# -----------------------------------------------------------------------------

# --- Management Group Outputs ------------------------------------------------

# TODO: Uncomment when management groups are created
# output "root_management_group_id" {
#   description = "Resource ID of the root management group"
#   value       = azurerm_management_group.root.id
# }

# output "platform_management_group_id" {
#   description = "Resource ID of the platform management group"
#   value       = azurerm_management_group.platform.id
# }

# output "workloads_management_group_id" {
#   description = "Resource ID of the workloads management group"
#   value       = azurerm_management_group.workloads.id
# }

# --- Policy Assignment Outputs -----------------------------------------------

# TODO: Uncomment when policy assignments are created
# output "security_benchmark_assignment_id" {
#   description = "Resource ID of the Azure Security Benchmark policy assignment"
#   value       = var.enable_policy_assignments ? azurerm_subscription_policy_assignment.azure_security_benchmark[0].id : null
# }

# output "require_tags_policy_id" {
#   description = "Resource ID of the require-tags custom policy definition"
#   value       = var.enable_policy_assignments ? azurerm_policy_definition.require_tags[0].id : null
# }

# output "deny_public_ip_policy_id" {
#   description = "Resource ID of the deny-public-ip custom policy definition"
#   value       = var.enable_policy_assignments ? azurerm_policy_definition.deny_public_ip[0].id : null
# }

# --- Budget Outputs ----------------------------------------------------------

# TODO: Uncomment when budget alerts are configured
# output "monthly_budget_id" {
#   description = "Resource ID of the monthly budget"
#   value       = var.enable_budget_alerts ? azurerm_consumption_budget_subscription.monthly[0].id : null
# }
