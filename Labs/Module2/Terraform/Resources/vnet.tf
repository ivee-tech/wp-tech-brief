resource "azurerm_virtual_network" "network" {
  name                = var.AKS_VNET
  location            = "East US"
  resource_group_name = var.AKS_RESOURCE_GROUP
  address_space       = var.AKS_VNET_ADDRESS_PREFIX

  subnet {
    name           = var.AKS_VNET_SUBNET
    address_prefix = var.AKS_VNET_SUBNET_PREFIX
  }
}
