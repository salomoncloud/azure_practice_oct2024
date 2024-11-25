
data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "enterprise_vault" {
  name                       = var.key_vault_name
  location                   = azurerm_resource_group.enterprise_rg.location
  resource_group_name        = azurerm_resource_group.enterprise_rg.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  soft_delete_retention_days = 7
  purge_protection_enabled   = false

  enable_rbac_authorization = false

  # Allow Azure services and specific IPs for access
  network_acls {
    default_action = "Deny"
    bypass         = "AzureServices"
    ip_rules       = concat(var.allowed_ip_range, [azurerm_public_ip.bastion_ip.ip_address])
  }

  depends_on = [azurerm_public_ip.bastion_ip]
}

# Access policy for the current user/service principal
resource "azurerm_key_vault_access_policy" "terraform" {
  key_vault_id = azurerm_key_vault.enterprise_vault.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  secret_permissions = [
    "Backup", "Delete", "Get", "List", "Purge", "Recover", "Restore", "Set"
  ]
}

# Access policy for the VMs' managed identities
resource "azurerm_key_vault_access_policy" "app_vm" {
  count        = 2
  key_vault_id = azurerm_key_vault.enterprise_vault.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_windows_virtual_machine.app_vm[count.index].identity[0].principal_id

  secret_permissions = [
    "Get", "List"
  ]
}

resource "azurerm_key_vault_access_policy" "db_vm" {
  key_vault_id = azurerm_key_vault.enterprise_vault.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_windows_virtual_machine.db_vm.identity[0].principal_id

  secret_permissions = [
    "Get", "List"
  ]
}

# Create secrets
resource "random_password" "app_vm_password" {
  length           = 16
  special          = true
  override_special = "!@#$%"
}

resource "random_password" "db_vm_password" {
  length           = 16
  special          = true
  override_special = "!@#$%"
}

resource "azurerm_key_vault_secret" "subscription_id" {
  name         = "subscription-id"
  value        = var.subscription_id
  key_vault_id = azurerm_key_vault.enterprise_vault.id

  depends_on = [
    azurerm_key_vault_access_policy.terraform
  ]
}

resource "azurerm_key_vault_secret" "app_vm_password" {
  name         = "app-vm-password"
  value        = random_password.app_vm_password.result
  key_vault_id = azurerm_key_vault.enterprise_vault.id

  depends_on = [
    azurerm_key_vault_access_policy.terraform
  ]
}

resource "azurerm_key_vault_secret" "db_vm_password" {
  name         = "db-vm-password"
  value        = random_password.db_vm_password.result
  key_vault_id = azurerm_key_vault.enterprise_vault.id

  depends_on = [
    azurerm_key_vault_access_policy.terraform
  ]
}