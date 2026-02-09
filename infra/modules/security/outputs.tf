# -----------------------------------------------------------------------------
# outputs.tf - Security Module Output Values
# -----------------------------------------------------------------------------
# Purpose: Exports security resource attributes for use by dependent modules
# (compute needs Key Vault ID, managed identity ID, etc.).
#
# Conventions:
#   - Sensitive outputs marked with sensitive = true
#   - Key Vault secrets are NOT output directly (use Key Vault references)
#
# Next steps:
#   - Uncomment outputs as resources are implemented
#   - Add outputs for managed identity principal ID
#   - Add outputs for policy assignment IDs
# -----------------------------------------------------------------------------

# --- Key Vault Outputs -------------------------------------------------------

# TODO: Uncomment when Key Vault is created
# output "key_vault_id" {
#   description = "Resource ID of the Azure Key Vault"
#   value       = azurerm_key_vault.main.id
# }

# output "key_vault_name" {
#   description = "Name of the Azure Key Vault"
#   value       = azurerm_key_vault.main.name
# }

# output "key_vault_uri" {
#   description = "URI of the Azure Key Vault"
#   value       = azurerm_key_vault.main.vault_uri
# }

# --- Managed Identity Outputs ------------------------------------------------

# TODO: Uncomment when managed identity is created
# output "vm_identity_id" {
#   description = "Resource ID of the VM managed identity"
#   value       = azurerm_user_assigned_identity.vm.id
# }

# output "vm_identity_principal_id" {
#   description = "Principal ID of the VM managed identity"
#   value       = azurerm_user_assigned_identity.vm.principal_id
# }

# output "vm_identity_client_id" {
#   description = "Client ID of the VM managed identity"
#   value       = azurerm_user_assigned_identity.vm.client_id
# }

# --- Secret References -------------------------------------------------------
# Note: Actual secret values are NOT output. Use Key Vault references instead.

# TODO: Uncomment when secrets are stored
# output "vm_admin_password_secret_id" {
#   description = "Key Vault secret ID for the VM admin password (use as reference)"
#   value       = azurerm_key_vault_secret.vm_admin_password.id
# }
