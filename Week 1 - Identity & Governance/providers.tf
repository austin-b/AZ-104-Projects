terraform {
    required_providers {
      azurerm = {
        source = "hashicorp/azurerm"
        version = "~> 3.100"
      }
      azuread = {
        source = "hashicorp/azuread"
        version = "~> 2.50"
      }
    }
}

provider "azurerm" {
    features {}
}

provider "azuread" {}