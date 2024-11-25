variable "location" {
  default = "Canada East"
}

variable "resource_group_name" {
  default = "CGI-Enterprise"
}

variable "admin" {
  default = "salomon.lubin@cgi.com"
}

variable "allowed_ip_range" {
  description = "IP range allowed for RDP access"
  default     = ["165.225.212.248"]
}

variable "subscription_id" {
  description = "Azure Subscription ID"
  type        = string
  sensitive   = true
}

variable "key_vault_name" {
  description = "Name of the Azure Key Vault"
  default     = "cgi-enterprise-kv"
}