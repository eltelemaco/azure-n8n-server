# -----------------------------------------------------------------------------
# main.tf - Landing Zone Core Module
# -----------------------------------------------------------------------------
# Purpose: Core landing zone module that establishes foundational Azure
# infrastructure. This module orchestrates the creation of the base
# resource group, diagnostic settings, and shared services that other
# modules depend on.
#
# This module provides:
#   - Resource group for the landing zone
#   - Log Analytics workspace for centralized logging
#   - Azure Monitor diagnostic settings
#   - Common tagging and naming conventions
#
# Conventions:
#   - Resource naming: <type>-<environment>-<location>-<name>
#   - All resources include common tags
#   - Outputs expose resource IDs for dependent modules
#
# Next steps:
#   - Implement resource group creation
#   - Add Log Analytics workspace for centralized monitoring
#   - Configure diagnostic settings for Azure Activity Log
#   - Add Azure Monitor action groups for alerting
# -----------------------------------------------------------------------------

# TODO: Implement landing zone foundational resources

# --- Resource Group ----------------------------------------------------------
# The primary resource group containing all landing zone resources

# resource "azurerm_resource_group" "landing_zone" {
#   name     = "rg-${var.environment}-${var.location}-${var.landing_zone_name}"
#   location = var.location
#   tags     = var.tags
# }

# --- Log Analytics Workspace -------------------------------------------------
# Centralized logging and monitoring for all landing zone resources

# resource "azurerm_log_analytics_workspace" "main" {
#   name                = "log-${var.environment}-${var.location}-landing-zone"
#   location            = azurerm_resource_group.landing_zone.location
#   resource_group_name = azurerm_resource_group.landing_zone.name
#   sku                 = "PerGB2018"
#   retention_in_days   = var.log_retention_days
#   tags                = var.tags
# }

# --- Azure Monitor Action Group ---------------------------------------------
# Default action group for critical alerts

# resource "azurerm_monitor_action_group" "critical" {
#   name                = "ag-${var.environment}-critical"
#   resource_group_name = azurerm_resource_group.landing_zone.name
#   short_name          = "critical"
#   tags                = var.tags
#
#   # TODO: Configure email, SMS, or webhook receivers
#   # email_receiver {
#   #   name          = "ops-team"
#   #   email_address = var.alert_email
#   # }
# }

# --- Activity Log Diagnostic Setting ----------------------------------------
# Forward Azure Activity Log to Log Analytics workspace

# resource "azurerm_monitor_diagnostic_setting" "activity_log" {
#   name                       = "diag-activity-log-to-workspace"
#   target_resource_id         = "/subscriptions/${data.azurerm_subscription.current.subscription_id}"
#   log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id
#
#   enabled_log {
#     category = "Administrative"
#   }
#   enabled_log {
#     category = "Security"
#   }
#   enabled_log {
#     category = "Alert"
#   }
# }
