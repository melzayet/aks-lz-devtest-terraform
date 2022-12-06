# Resource Group for Landing Zone Networking
# This RG uses the same region location as the Hub.
resource "azurerm_resource_group" "spoke-rg" {
  name     = "${var.lz_prefix}-SPOKE"
  location = data.terraform_remote_state.existing-hub.outputs.hub_rg_location
}

output "lz_rg_location" {
  value = azurerm_resource_group.spoke-rg.location
}

output "lz_rg_name" {
  value = azurerm_resource_group.spoke-rg.name
}


# Virtual Network

resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-${var.lz_prefix}"
  resource_group_name = azurerm_resource_group.spoke-rg.name
  location            = azurerm_resource_group.spoke-rg.location
  address_space       = ["10.1.0.0/16"]
  dns_servers         = null
  tags                = var.tags

}

output "lz_vnet_name" {
  value = azurerm_virtual_network.vnet.name
}

output "lz_vnet_id" {
  value = azurerm_virtual_network.vnet.id
}