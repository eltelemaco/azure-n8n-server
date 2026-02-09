# -----------------------------------------------------------------------------
# main.tf - Networking Module
# -----------------------------------------------------------------------------
# Purpose: Implements hub-and-spoke virtual network topology for the Azure
# landing zone. Provides network isolation, segmentation, and connectivity
# following Azure Well-Architected Framework networking best practices.
#
# This module creates:
#   - Hub virtual network (shared services, VPN/ExpressRoute gateway)
#   - Spoke virtual network (workload-specific)
#   - VNet peering between hub and spoke
#   - Subnets segregated by tier (web, app, data, management)
#   - Network Security Groups (NSGs) with deny-by-default rules
#   - Azure Bastion subnet and host (optional)
#
# Conventions:
#   - Resource naming: <type>-<environment>-<location>-<name>
#   - NSGs applied at subnet level
#   - No public IPs without explicit justification
#   - Address spaces must not overlap between environments
#
# Next steps:
#   - Implement hub VNet with gateway and management subnets
#   - Implement spoke VNet with workload subnets
#   - Configure VNet peering (hub-to-spoke and spoke-to-hub)
#   - Create NSG rules following least-privilege principle
#   - Add Azure Bastion for secure VM access
#   - Add route tables for custom routing (if needed)
# -----------------------------------------------------------------------------

# TODO: Implement networking resources

# --- Hub Virtual Network -----------------------------------------------------

# resource "azurerm_virtual_network" "hub" {
#   name                = "vnet-${var.environment}-${var.location}-hub"
#   location            = var.location
#   resource_group_name = var.resource_group_name
#   address_space       = var.hub_vnet_address_space
#   tags                = var.tags
# }

# --- Hub Subnets -------------------------------------------------------------

# Management subnet for shared services
# resource "azurerm_subnet" "mgmt" {
#   name                 = "snet-${var.environment}-mgmt"
#   resource_group_name  = var.resource_group_name
#   virtual_network_name = azurerm_virtual_network.hub.name
#   address_prefixes     = [var.mgmt_subnet_prefix]
# }

# Azure Bastion subnet (name must be "AzureBastionSubnet")
# resource "azurerm_subnet" "bastion" {
#   count                = var.enable_bastion ? 1 : 0
#   name                 = "AzureBastionSubnet"
#   resource_group_name  = var.resource_group_name
#   virtual_network_name = azurerm_virtual_network.hub.name
#   address_prefixes     = [var.bastion_subnet_prefix]
# }

# --- Spoke Virtual Network ---------------------------------------------------

# resource "azurerm_virtual_network" "spoke" {
#   name                = "vnet-${var.environment}-${var.location}-spoke"
#   location            = var.location
#   resource_group_name = var.resource_group_name
#   address_space       = var.spoke_vnet_address_space
#   tags                = var.tags
# }

# --- Spoke Subnets -----------------------------------------------------------

# Web tier subnet
# resource "azurerm_subnet" "web" {
#   name                 = "snet-${var.environment}-web"
#   resource_group_name  = var.resource_group_name
#   virtual_network_name = azurerm_virtual_network.spoke.name
#   address_prefixes     = [var.web_subnet_prefix]
# }

# Application tier subnet
# resource "azurerm_subnet" "app" {
#   name                 = "snet-${var.environment}-app"
#   resource_group_name  = var.resource_group_name
#   virtual_network_name = azurerm_virtual_network.spoke.name
#   address_prefixes     = [var.app_subnet_prefix]
# }

# Data tier subnet
# resource "azurerm_subnet" "data" {
#   name                 = "snet-${var.environment}-data"
#   resource_group_name  = var.resource_group_name
#   virtual_network_name = azurerm_virtual_network.spoke.name
#   address_prefixes     = [var.data_subnet_prefix]
# }

# --- VNet Peering ------------------------------------------------------------

# Hub to Spoke peering
# resource "azurerm_virtual_network_peering" "hub_to_spoke" {
#   name                      = "peer-hub-to-spoke"
#   resource_group_name       = var.resource_group_name
#   virtual_network_name      = azurerm_virtual_network.hub.name
#   remote_virtual_network_id = azurerm_virtual_network.spoke.id
#   allow_forwarded_traffic   = true
#   allow_gateway_transit     = true
# }

# Spoke to Hub peering
# resource "azurerm_virtual_network_peering" "spoke_to_hub" {
#   name                      = "peer-spoke-to-hub"
#   resource_group_name       = var.resource_group_name
#   virtual_network_name      = azurerm_virtual_network.spoke.name
#   remote_virtual_network_id = azurerm_virtual_network.hub.id
#   allow_forwarded_traffic   = true
#   use_remote_gateways       = false
# }

# --- Network Security Groups ------------------------------------------------

# NSG for application subnet (deny-by-default)
# resource "azurerm_network_security_group" "app" {
#   name                = "nsg-${var.environment}-${var.location}-app"
#   location            = var.location
#   resource_group_name = var.resource_group_name
#   tags                = var.tags
#
#   # TODO: Add security rules following least-privilege principle
#   # Example: Allow HTTPS inbound from web subnet
#   # security_rule {
#   #   name                       = "AllowHTTPSFromWeb"
#   #   priority                   = 100
#   #   direction                  = "Inbound"
#   #   access                     = "Allow"
#   #   protocol                   = "Tcp"
#   #   source_port_range          = "*"
#   #   destination_port_range     = "443"
#   #   source_address_prefix      = var.web_subnet_prefix
#   #   destination_address_prefix = "*"
#   #   description                = "Allow HTTPS traffic from web tier"
#   #  }
# }

# --- Azure Bastion -----------------------------------------------------------

# resource "azurerm_bastion_host" "main" {
#   count               = var.enable_bastion ? 1 : 0
#   name                = "bas-${var.environment}-${var.location}"
#   location            = var.location
#   resource_group_name = var.resource_group_name
#   tags                = var.tags
#
#   ip_configuration {
#     name                 = "bastion-ip-config"
#     subnet_id            = azurerm_subnet.bastion[0].id
#     public_ip_address_id = azurerm_public_ip.bastion[0].id
#   }
# }
