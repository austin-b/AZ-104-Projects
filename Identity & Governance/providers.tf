terraform {
  required_version = ">= 1.6.0"

  required_providers {
    # for general Azure resource management
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    # for Azure Entra ID management
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
}

provider "azuread" {
  tenant_id = var.tenant_id
}
