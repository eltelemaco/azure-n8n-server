# -----------------------------------------------------------------------------
# outputs.tf - Compute Module Output Values
# -----------------------------------------------------------------------------
# Purpose: Exports compute resource attributes for use by dependent modules
# and environment configurations. Sensitive values (passwords) are marked
# appropriately.
#
# Conventions:
#   - Sensitive outputs marked with sensitive = true
#   - VM IDs and IPs exposed as lists for multiple instances
#
# Next steps:
#   - Uncomment outputs as resources are implemented
#   - Add outputs for VM principal IDs (managed identity)
#   - Add outputs for boot diagnostics storage URI
# -----------------------------------------------------------------------------

# --- VM Outputs --------------------------------------------------------------

# TODO: Uncomment when VMs are created
# output "vm_ids" {
#   description = "List of VM resource IDs"
#   value       = azurerm_linux_virtual_machine.main[*].id
# }

# output "vm_names" {
#   description = "List of VM names"
#   value       = azurerm_linux_virtual_machine.main[*].name
# }

# output "vm_private_ips" {
#   description = "List of VM private IP addresses"
#   value       = azurerm_network_interface.vm[*].private_ip_address
# }

# --- Authentication Outputs --------------------------------------------------

# output "admin_password" {
#   description = "Administrator password for VM instances"
#   value       = var.admin_password
#   sensitive   = true
# }

# --- Network Interface Outputs -----------------------------------------------

# output "nic_ids" {
#   description = "List of network interface resource IDs"
#   value       = azurerm_network_interface.vm[*].id
# }
