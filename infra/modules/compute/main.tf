# -----------------------------------------------------------------------------
# main.tf - Compute Module
# -----------------------------------------------------------------------------
# Purpose: Implements compute resources for the Azure landing zone including
# Linux VM instances with secure configuration following Azure best practices.
#
# This module creates:
#   - Linux virtual machines with managed disks
#   - Network interfaces attached to specified subnets
#   - Boot diagnostics for VM troubleshooting
#   - Azure Monitor agent for observability
#   - SSH key pair generation (stored in Key Vault)
#
# Security best practices:
#   - No public IP addresses (access via Azure Bastion)
#   - Admin password stored in Azure Key Vault
#   - Managed identity for Azure resource access
#   - Azure Disk Encryption enabled
#   - Azure Monitor agent for security logging
#
# Conventions:
#   - Resource naming: <type>-<environment>-<location>-<name>-<index>
#   - VMs placed in application subnet
#   - Premium managed disks for production workloads
#
# Next steps:
#   - Implement VM resource with network interface
#   - Configure OS disk with encryption
#   - Add boot diagnostics storage
#   - Install Azure Monitor agent extension
#   - Configure managed identity association
#   - Add availability set or zone configuration for HA
# -----------------------------------------------------------------------------

# TODO: Implement compute resources

# --- Network Interfaces ------------------------------------------------------
# One NIC per VM, attached to the application subnet

# resource "azurerm_network_interface" "vm" {
#   count               = var.vm_instance_count
#   name                = "nic-${var.environment}-${var.location}-vm-${format("%03d", count.index + 1)}"
#   location            = var.location
#   resource_group_name = var.resource_group_name
#   tags                = var.tags
#
#   ip_configuration {
#     name                          = "internal"
#     subnet_id                     = var.subnet_id
#     private_ip_address_allocation = "Dynamic"
#     # Note: No public IP - access via Azure Bastion
#   }
# }

# --- Linux Virtual Machines --------------------------------------------------

# resource "azurerm_linux_virtual_machine" "main" {
#   count               = var.vm_instance_count
#   name                = "${var.vm_name_prefix}-${format("%03d", count.index + 1)}"
#   location            = var.location
#   resource_group_name = var.resource_group_name
#   size                = var.vm_size
#   admin_username      = var.admin_username
#   tags                = var.tags
#
#   # Network configuration
#   network_interface_ids = [azurerm_network_interface.vm[count.index].id]
#
#   # Authentication - password from Key Vault, SSH key generated
#   admin_password                  = var.admin_password
#   disable_password_authentication = false
#
#   # TODO: Add SSH key authentication
#   # admin_ssh_key {
#   #   username   = var.admin_username
#   #   public_key = tls_private_key.ssh.public_key_openssh
#   # }
#
#   # OS disk configuration
#   os_disk {
#     name                 = "osdisk-${var.vm_name_prefix}-${format("%03d", count.index + 1)}"
#     caching              = var.os_disk_caching
#     storage_account_type = var.os_disk_type
#   }
#
#   # Source image
#   source_image_reference {
#     publisher = var.image_publisher
#     offer     = var.image_offer
#     sku       = var.image_sku
#     version   = var.image_version
#   }
#
#   # Managed identity for Azure resource access
#   identity {
#     type         = "UserAssigned"
#     identity_ids = var.managed_identity_ids
#   }
#
#   # Boot diagnostics for troubleshooting
#   boot_diagnostics {
#     # Uses managed storage account when storage_account_uri is omitted
#   }
#
#   lifecycle {
#     ignore_changes = [
#       # Ignore changes to admin_password after initial creation
#       admin_password,
#     ]
#   }
# }

# --- VM Extensions -----------------------------------------------------------
# Azure Monitor Agent for logging and metrics

# resource "azurerm_virtual_machine_extension" "ama" {
#   count                = var.enable_monitoring ? var.vm_instance_count : 0
#   name                 = "AzureMonitorLinuxAgent"
#   virtual_machine_id   = azurerm_linux_virtual_machine.main[count.index].id
#   publisher            = "Microsoft.Azure.Monitor"
#   type                 = "AzureMonitorLinuxAgent"
#   type_handler_version = "1.0"
#   auto_upgrade_minor_version = true
#   tags                 = var.tags
# }
