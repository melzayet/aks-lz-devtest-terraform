
# Virtual Network for Hub
# -----------------------

resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-${var.hub_prefix}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  address_space       = ["10.0.0.0/16"]
  dns_servers         = null
  tags                = var.tags

}

# SUBNETS on Hub Network
# ----------------------


# Gateway Subnet 
# (Additional subnet for Gateway, without NSG as per requirements)
resource "azurerm_subnet" "gateway" {
  name                                           = "GatewaySubnet"
  resource_group_name                            = azurerm_resource_group.rg.name
  virtual_network_name                           = azurerm_virtual_network.vnet.name
  address_prefixes                               = ["10.0.2.0/27"]
  enforce_private_link_endpoint_network_policies = false

}

#############
## OUTPUTS ##
#############
# These outputs are used by later deployments

output "hub_vnet_name" {
  value = azurerm_virtual_network.vnet.name
}

output "hub_vnet_id" {
  value = azurerm_virtual_network.vnet.id
}

output "hub_gateway_subnet_id" {
  value = azurerm_subnet.gateway.id
}
