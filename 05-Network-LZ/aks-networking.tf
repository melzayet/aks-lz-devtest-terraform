
# This section create a subnet for AKS along with an associated NSG.
# "Here be dragons!" <-- Must elaborate

resource "azurerm_subnet" "aks" {
  name                                           = "aksSubnet"
  resource_group_name                            = azurerm_resource_group.spoke-rg.name
  virtual_network_name                           = azurerm_virtual_network.vnet.name
  address_prefixes                               = ["10.1.16.0/24"]
  private_link_service_network_policies_enabled = false
}

output "aks_subnet_id" {
  value = azurerm_subnet.aks.id
}

resource "azurerm_subnet" "pod" {
  name                                           = "podSubnet"
  resource_group_name                            = azurerm_resource_group.spoke-rg.name
  virtual_network_name                           = azurerm_virtual_network.vnet.name
  address_prefixes                               = ["10.1.24.0/21"]
  private_link_service_network_policies_enabled = true

}

output "pod_subnet_id" {
  value = azurerm_subnet.pod.id
}

resource "azurerm_subnet" "spotPod" {
  name                                           = "spotPodSubnet"
  resource_group_name                            = azurerm_resource_group.spoke-rg.name
  virtual_network_name                           = azurerm_virtual_network.vnet.name
  address_prefixes                               = ["10.1.32.0/21"]
  private_link_service_network_policies_enabled = true
}

output "spotPod_subnet_id" {
  value = azurerm_subnet.spotPod.id
}

resource "azurerm_network_security_group" "aks-nsg" {
  name                = "${azurerm_virtual_network.vnet.name}-${azurerm_subnet.aks.name}-nsg"
  resource_group_name = azurerm_resource_group.spoke-rg.name
  location            = azurerm_resource_group.spoke-rg.location
}

resource "azurerm_network_security_rule" "allow-http" {
  name                        = "allow-http"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.spoke-rg.name
  network_security_group_name = azurerm_network_security_group.aks-nsg.name
}

resource "azurerm_network_security_rule" "allow-https" {
  name                        = "allow-https"
  priority                    = 110
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.spoke-rg.name
  network_security_group_name = azurerm_network_security_group.aks-nsg.name
}

resource "azurerm_network_security_group" "pod-nsg" {
  name                = "${azurerm_virtual_network.vnet.name}-${azurerm_subnet.aks.name}-pod-nsg"
  resource_group_name = azurerm_resource_group.spoke-rg.name
  location            = azurerm_resource_group.spoke-rg.location
}

resource "azurerm_subnet_network_security_group_association" "aksSubnet" {
  subnet_id                 = azurerm_subnet.aks.id
  network_security_group_id = azurerm_network_security_group.aks-nsg.id
}

resource "azurerm_subnet_network_security_group_association" "podSubnet" {
  subnet_id                 = azurerm_subnet.pod.id
  network_security_group_id = azurerm_network_security_group.pod-nsg.id
}

resource "azurerm_subnet_network_security_group_association" "spotPodSubnet" {
  subnet_id                 = azurerm_subnet.spotPod.id
  network_security_group_id = azurerm_network_security_group.pod-nsg.id
}

resource "azurerm_public_ip" "natGWPIP" {
  name                = "nat-gateway-publicIP"
  location            = azurerm_resource_group.spoke-rg.location
  resource_group_name = azurerm_resource_group.spoke-rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = ["1"]
}

resource "azurerm_nat_gateway" "natGW" {
  name                    = "nat-Gateway"
  location                = azurerm_resource_group.spoke-rg.location
  resource_group_name     = azurerm_resource_group.spoke-rg.name
  sku_name                = "Standard"
  idle_timeout_in_minutes = 10
  zones                   = ["1"]
}

resource "azurerm_nat_gateway_public_ip_association" "pipassoc" {
  nat_gateway_id       = azurerm_nat_gateway.natGW.id
  public_ip_address_id = azurerm_public_ip.natGWPIP.id
}

resource "azurerm_subnet_nat_gateway_association" "subnetassoc" {
  subnet_id      = azurerm_subnet.aks.id
  nat_gateway_id = azurerm_nat_gateway.natGW.id
}