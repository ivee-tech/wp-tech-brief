resource "azurerm_storage_account" "storage" {
  name                      = var.STORAGE_ACCOUNT_NAME
  location                  = "East US"
  resource_group_name       = var.AKS_RESOURCE_GROUP
  account_kind              = "StorageV2"
  account_tier              = "Standard"
  account_replication_type  = "LRS"
  access_tier               = "Hot"
  enable_https_traffic_only = true
}
