
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
  private_link_service_network_policies_enabled = false
}

output "pod_subnet_id" {
  value = azurerm_subnet.pod.id
}

resource "azurerm_subnet" "spotPod" {
  name                                           = "spotPodSubnet"
  resource_group_name                            = azurerm_resource_group.spoke-rg.name
  virtual_network_name                           = azurerm_virtual_network.vnet.name
  address_prefixes                               = ["10.1.32.0/21"]
  private_link_service_network_policies_enabled = false
}

output "spotPod_subnet_id" {
  value = azurerm_subnet.spotPod.id
}

resource "azurerm_network_security_group" "aks-nsg" {
  name                = "${azurerm_virtual_network.vnet.name}-${azurerm_subnet.aks.name}-nsg"
  resource_group_name = azurerm_resource_group.spoke-rg.name
  location            = azurerm_resource_group.spoke-rg.location
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