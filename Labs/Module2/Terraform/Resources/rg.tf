resource "azurerm_resource_group" "arg" {
  name     = var.AKS_RESOURCE_GROUP
  location = "East US"
}