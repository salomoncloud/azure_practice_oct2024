terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.6.0"
    }
  }
}

provider "azurerm" {
  features {}
  use_cli                         = true
  subscription_id                 = var.subscription_id
  resource_provider_registrations = "core"
}

resource "azurerm_resource_group" "enterprise_rg" {
  name     = var.resource_group_name
  location = var.location
}