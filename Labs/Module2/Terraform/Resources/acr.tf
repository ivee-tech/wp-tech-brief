resource "azurerm_container_registry" "acr" {
  name                = var.ACR
  location            = "East US"
  resource_group_name = var.AKS_RESOURCE_GROUP
  sku                 = "Standard"
  admin_enabled       = false
}
