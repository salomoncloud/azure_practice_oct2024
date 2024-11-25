resource "azurerm_virtual_network" "enterprise_vnet" {
  name                = "CGIEnterpriseVNet"
  address_space       = ["10.1.0.0/16"]
  location            = var.location
  resource_group_name = azurerm_resource_group.enterprise_rg.name
}

resource "azurerm_subnet" "app_subnet" {
  name                 = "AppSubnet"
  resource_group_name  = azurerm_resource_group.enterprise_rg.name
  virtual_network_name = azurerm_virtual_network.enterprise_vnet.name
  address_prefixes     = ["10.1.1.0/24"]
}

resource "azurerm_subnet" "data_subnet" {
  name                 = "DataSubnet"
  resource_group_name  = azurerm_resource_group.enterprise_rg.name
  virtual_network_name = azurerm_virtual_network.enterprise_vnet.name
  address_prefixes     = ["10.1.2.0/24"]
}

resource "azurerm_subnet" "bastion_subnet" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.enterprise_rg.name
  virtual_network_name = azurerm_virtual_network.enterprise_vnet.name
  address_prefixes     = ["10.1.3.0/24"]
}

# Application NSG associated with AppSubnet
resource "azurerm_network_security_group" "app_nsg" {
  name                = "app-nsg"
  location            = azurerm_resource_group.enterprise_rg.location
  resource_group_name = azurerm_resource_group.enterprise_rg.name

  security_rule {
    name                       = "allow-rdp"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefixes    = var.allowed_ip_range
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow-http"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  depends_on = [azurerm_subnet.app_subnet, azurerm_subnet.data_subnet]
}

resource "azurerm_subnet_network_security_group_association" "app_nsg_association" {
  subnet_id                 = azurerm_subnet.app_subnet.id
  network_security_group_id = azurerm_network_security_group.app_nsg.id
}

# Data NSG associated with DataSubnet
resource "azurerm_network_security_group" "data_nsg" {
  name                = "data-nsg"
  location            = azurerm_resource_group.enterprise_rg.location
  resource_group_name = azurerm_resource_group.enterprise_rg.name

  security_rule {
    name                       = "allow-sql"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "1433"
    source_address_prefix      = "10.1.1.0/24"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "data_nsg_association" {
  subnet_id                 = azurerm_subnet.data_subnet.id
  network_security_group_id = azurerm_network_security_group.data_nsg.id
}


# load balancer

resource "azurerm_public_ip" "lb_ip" {
  name                = "lb-public-ip"
  location            = azurerm_resource_group.enterprise_rg.location
  resource_group_name = azurerm_resource_group.enterprise_rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_lb" "app_lb" {
  name                = "EnterpriseAppLoadBalancer"
  location            = azurerm_resource_group.enterprise_rg.location
  resource_group_name = azurerm_resource_group.enterprise_rg.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "app_lb_frontend"
    public_ip_address_id = azurerm_public_ip.lb_ip.id
  }

  depends_on = [azurerm_virtual_network.enterprise_vnet]
}

resource "azurerm_lb_backend_address_pool" "app_lb_pool" {
  name            = "AppLBBackendPool"
  loadbalancer_id = azurerm_lb.app_lb.id
}

resource "azurerm_lb_probe" "app_probe" {
  loadbalancer_id = azurerm_lb.app_lb.id
  name            = "http-probe"
  protocol        = "Http"
  port            = 80
  request_path    = "/"
}

resource "azurerm_lb_rule" "https_rule" {
  name                           = "HttpsRule"
  loadbalancer_id                = azurerm_lb.app_lb.id
  frontend_ip_configuration_name = azurerm_lb.app_lb.frontend_ip_configuration[0].name
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.app_lb_pool.id]
  protocol                       = "Tcp"
  frontend_port                  = 443
  backend_port                   = 443
  probe_id                       = azurerm_lb_probe.app_probe.id
}

resource "azurerm_lb_rule" "http_rule" {
  name                           = "HttpRule"
  loadbalancer_id                = azurerm_lb.app_lb.id
  frontend_ip_configuration_name = azurerm_lb.app_lb.frontend_ip_configuration[0].name
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.app_lb_pool.id]
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  probe_id                       = azurerm_lb_probe.app_probe.id
}
