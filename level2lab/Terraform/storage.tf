
resource "azurerm_storage_account" "enterprise_storage" {
  name                     = "cgienterprisestorage"
  resource_group_name      = azurerm_resource_group.enterprise_rg.name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
  depends_on               = [azurerm_virtual_network.enterprise_vnet]
}

resource "azurerm_storage_container" "data_container" {
  name                  = "enterprise-data"
  storage_account_name  = azurerm_storage_account.enterprise_storage.name
  container_access_type = "private"
}

resource "azurerm_storage_blob" "data_blob" {
  name                   = "initial-config.json"
  storage_account_name   = azurerm_storage_account.enterprise_storage.name
  storage_container_name = azurerm_storage_container.data_container.name
  type                   = "Block"
  source                 = "C:/Users/salomon.lubin/Desktop/level2lab/Terraform/initial-config.json"
}
