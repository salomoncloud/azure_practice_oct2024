
output "bastion_public_ip" {
  value       = azurerm_public_ip.bastion_ip.ip_address
  description = "Public IP address of the Bastion host"
}

output "app_vm_private_ips" {
  value = azurerm_network_interface.app_nic[*].private_ip_address
}

output "db_vm_private_ip" {
  value = azurerm_network_interface.db_nic.private_ip_address
}

output "load_balancer_ip" {
  value = azurerm_public_ip.lb_ip.ip_address
}

output "key_vault_name" {
  value = azurerm_key_vault.enterprise_vault.name
}

output "key_vault_uri" {
  value = azurerm_key_vault.enterprise_vault.vault_uri
}
