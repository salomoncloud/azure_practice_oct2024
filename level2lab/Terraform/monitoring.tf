
# CPU, Memory, and Disk I/O Alerts for App VMs
resource "azurerm_monitor_metric_alert" "cpu_alert_app_vm" {
  count               = 2
  name                = "appvm-cpu-alert-${count.index + 1}"
  resource_group_name = azurerm_resource_group.enterprise_rg.name
  scopes              = [azurerm_windows_virtual_machine.app_vm[count.index].id]
  description         = "Alert when CPU usage exceeds 80% on App VMs"

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "Percentage CPU"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 80
  }
}

resource "azurerm_monitor_metric_alert" "memory_alert_app_vm" {
  count               = 2
  name                = "appvm-memory-alert-${count.index + 1}"
  resource_group_name = azurerm_resource_group.enterprise_rg.name
  scopes              = [azurerm_windows_virtual_machine.app_vm[count.index].id]
  description         = "Alert when Available Memory falls below 500 MB on App VMs"

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "Available Memory Bytes"
    aggregation      = "Average"
    operator         = "LessThan"
    threshold        = 500000000 # 500 MB in bytes
  }
}

resource "azurerm_monitor_metric_alert" "disk_io_alert_app_vm" {
  count               = 2
  name                = "appvm-disk-io-alert-${count.index + 1}"
  resource_group_name = azurerm_resource_group.enterprise_rg.name
  scopes              = [azurerm_windows_virtual_machine.app_vm[count.index].id]
  description         = "Alert when Disk Bytes Read/Write exceed 100 MB on App VMs"

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "Disk Write Bytes"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = 100000000 # 100 MB in bytes
  }
}

# CPU, Memory, and Disk I/O Alerts for DB VM
resource "azurerm_monitor_metric_alert" "cpu_alert_dbvm" {
  name                = "dbvm-cpu-alert"
  resource_group_name = azurerm_resource_group.enterprise_rg.name
  scopes              = [azurerm_windows_virtual_machine.db_vm.id]
  description         = "Alert when CPU usage exceeds 80% on DB VM"

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "Percentage CPU"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 80
  }
}

resource "azurerm_monitor_metric_alert" "memory_alert_dbvm" {
  name                = "dbvm-memory-alert"
  resource_group_name = azurerm_resource_group.enterprise_rg.name
  scopes              = [azurerm_windows_virtual_machine.db_vm.id]
  description         = "Alert when Available Memory falls below 500 MB on DB VM"

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "Available Memory Bytes"
    aggregation      = "Average"
    operator         = "LessThan"
    threshold        = 500000000 # 500 MB in bytes
  }
}

resource "azurerm_monitor_metric_alert" "disk_io_alert_dbvm" {
  name                = "dbvm-disk-io-alert"
  resource_group_name = azurerm_resource_group.enterprise_rg.name
  scopes              = [azurerm_windows_virtual_machine.db_vm.id]
  description         = "Alert when Disk Bytes Read/Write exceed 100 MB on DB VM"

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "Disk Write Bytes"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = 100000000 # 100 MB in bytes
  }
}

# Action Group Configuration (Shared)
resource "azurerm_monitor_action_group" "action_group_lvl2" {
  name                = "actionGroup_lablvl2"
  resource_group_name = azurerm_resource_group.enterprise_rg.name
  short_name          = "lvl2"

  email_receiver {
    name          = "admin"
    email_address = var.admin
  }
}
