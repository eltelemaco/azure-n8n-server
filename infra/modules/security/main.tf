# -----------------------------------------------------------------------------
# main.tf - Security Module
# -----------------------------------------------------------------------------
# Purpose: Implements security infrastructure for the Azure landing zone
# including Azure Key Vault for secrets management, Azure Policy for
# compliance, and RBAC role assignments.
#
# This module creates:
#   - Azure Key Vault for storing secrets, keys, and certificates
#   - Azure Policy definitions and assignments
#   - RBAC role assignments for least-privilege access
#   - Managed identities for Azure resources
#
# Security principles:
#   - Secrets stored in Key Vault, never in Terraform state or code
#   - Managed identities preferred over service principals
#   - Least-privilege RBAC assignments
#   - Azure Policy enforces organizational standards
#   - Network restrictions on Key Vault (private endpoint recommended)
#
# Conventions:
#   - Resource naming: <type>-<environment>-<location>-<name>
#   - Key Vault uses soft delete and purge protection
#   - All access via RBAC (not access policies)
#
# Next steps:
#   - Implement Key Vault with RBAC authorization
#   - Add managed identity for VM access
#   - Configure Azure Policy definitions for compliance
#   - Add private endpoint for Key Vault (production)
#   - Set up Key Vault diagnostic settings
# -----------------------------------------------------------------------------

# TODO: Implement security resources

# --- Data Sources ------------------------------------------------------------

# Get current Azure client configuration for Key Vault access
# data "azurerm_client_config" "current" {}

# --- Azure Key Vault ---------------------------------------------------------
# Centralized secrets management with RBAC-based access control

# resource "azurerm_key_vault" "main" {
#   name                = "kv-${var.environment}-${var.location}-lz"
#   location            = var.location
#   resource_group_name = var.resource_group_name
#   tenant_id           = data.azurerm_client_config.current.tenant_id
#   sku_name            = "standard"
#
#   # Security settings
#   enabled_for_disk_encryption     = true
#   enabled_for_deployment          = true
#   enabled_for_template_deployment = false
#   soft_delete_retention_days      = 90
#   purge_protection_enabled        = var.environment == "production" ? true : false
#   enable_rbac_authorization       = true
#
#   # Network rules (restrict in production)
#   network_acls {
#     bypass         = "AzureServices"
#     default_action = var.environment == "production" ? "Deny" : "Allow"
#   }
#
#   tags = var.tags
# }

# --- Key Vault RBAC ----------------------------------------------------------
# Assign Key Vault Administrator role to the current user/service principal

# resource "azurerm_role_assignment" "kv_admin" {
#   scope                = azurerm_key_vault.main.id
#   role_definition_name = "Key Vault Administrator"
#   principal_id         = data.azurerm_client_config.current.object_id
# }

# --- Managed Identity --------------------------------------------------------
# User-assigned managed identity for VM and resource access

# resource "azurerm_user_assigned_identity" "vm" {
#   name                = "id-${var.environment}-${var.location}-vm"
#   location            = var.location
#   resource_group_name = var.resource_group_name
#   tags                = var.tags
# }

# --- Key Vault Secrets -------------------------------------------------------
# Store generated secrets in Key Vault

# resource "random_password" "vm_admin" {
#   length           = 32
#   special          = true
#   min_upper        = 2
#   min_lower        = 2
#   min_numeric      = 2
#   min_special      = 2
#   override_special = "!@#$%&*()-_=+"
# }

# resource "azurerm_key_vault_secret" "vm_admin_password" {
#   name         = "vm-admin-password"
#   value        = random_password.vm_admin.result
#   key_vault_id = azurerm_key_vault.main.id
#
#   depends_on = [azurerm_role_assignment.kv_admin]
# }

# --- Key Vault Diagnostic Settings ------------------------------------------
# Forward Key Vault logs to Log Analytics

# resource "azurerm_monitor_diagnostic_setting" "kv" {
#   name                       = "diag-kv-to-workspace"
#   target_resource_id         = azurerm_key_vault.main.id
#   log_analytics_workspace_id = var.log_analytics_workspace_id
#
#   enabled_log {
#     category = "AuditEvent"
#   }
#
#   metric {
#     category = "AllMetrics"
#     enabled  = true
#   }
# }
