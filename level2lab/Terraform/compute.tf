resource "azurerm_bastion_host" "enterprise_bastion" {
  name                = "EnterpriseBastionHost"
  location            = azurerm_resource_group.enterprise_rg.location
  resource_group_name = azurerm_resource_group.enterprise_rg.name
  ip_configuration {
    name                 = "default"
    subnet_id            = azurerm_subnet.bastion_subnet.id
    public_ip_address_id = azurerm_public_ip.bastion_ip.id
  }
}

resource "azurerm_public_ip" "bastion_ip" {
  name                = "bastion-ip"
  location            = azurerm_resource_group.enterprise_rg.location
  resource_group_name = azurerm_resource_group.enterprise_rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Virtual Machines
resource "azurerm_windows_virtual_machine" "app_vm" {
  count               = 2
  name                = "EntrpriseAppVM${count.index + 1}"
  location            = azurerm_resource_group.enterprise_rg.location
  resource_group_name = azurerm_resource_group.enterprise_rg.name
  size                = "Standard_D2s_v3"
  admin_username      = "adminuser"
  admin_password      = random_password.app_vm_password.result

  network_interface_ids = [
    azurerm_network_interface.app_nic[count.index].id
  ]

  identity {
    type = "SystemAssigned"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }

  depends_on = [azurerm_key_vault.enterprise_vault, azurerm_storage_account.enterprise_storage]
}

resource "azurerm_windows_virtual_machine" "db_vm" {
  name                = "EnterpriseDBVM"
  location            = azurerm_resource_group.enterprise_rg.location
  resource_group_name = azurerm_resource_group.enterprise_rg.name
  size                = "Standard_D4s_v3"
  admin_username      = "adminuser"
  admin_password      = random_password.db_vm_password.result

  network_interface_ids = [
    azurerm_network_interface.db_nic.id
  ]

  identity {
    type = "SystemAssigned"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftSQLServer"
    offer     = "SQL2019-WS2019"
    sku       = "Standard"
    version   = "latest"
  }
}

resource "azurerm_public_ip" "app_vm_public_ip" {
  count               = 2
  name                = "app-vm-public-ip-${count.index + 1}"
  location            = azurerm_resource_group.enterprise_rg.location
  resource_group_name = azurerm_resource_group.enterprise_rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_interface" "app_nic" {
  count               = 2
  name                = "app-nic-${count.index + 1}"
  location            = azurerm_resource_group.enterprise_rg.location
  resource_group_name = azurerm_resource_group.enterprise_rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.app_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.app_vm_public_ip[count.index].id
  }
}

# Associate each NIC with the load balancer’s backend pool
resource "azurerm_network_interface_backend_address_pool_association" "app_nic_lb_association" {
  count                   = 2
  network_interface_id    = azurerm_network_interface.app_nic[count.index].id
  ip_configuration_name   = "internal"
  backend_address_pool_id = azurerm_lb_backend_address_pool.app_lb_pool.id
}

resource "azurerm_network_interface" "db_nic" {
  name                = "db-nic"
  location            = azurerm_resource_group.enterprise_rg.location
  resource_group_name = azurerm_resource_group.enterprise_rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.data_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

# Custom Script Extension to install IIS
resource "azurerm_virtual_machine_extension" "app_vm_extension" {
  count                = 2
  name                 = "IISSetup${count.index + 1}"
  virtual_machine_id   = azurerm_windows_virtual_machine.app_vm[count.index].id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"

  settings = <<SETTINGS
  {
    "commandToExecute": "powershell.exe -ExecutionPolicy Unrestricted -Command \"Install-WindowsFeature -Name Web-Server -IncludeAllSubFeature -IncludeManagementTools"
  }
  SETTINGS
}
