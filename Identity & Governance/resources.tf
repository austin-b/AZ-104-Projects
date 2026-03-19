# create prod resource group
resource "azurerm_resource_group" "prod" {
  name     = "rg-prod"
  location = "East US"
}

# create dev resource group
resource "azurerm_resource_group" "dev" {
  name     = "rg-dev"
  location = "East US"
}

# create staging resource group
resource "azurerm_resource_group" "staging" {
  name     = "rg-staging"
  location = "East US"
}

# creating three new users using the "users" module
module "users" {
  source = "./modules/users"

  users = {
    admin-user = {
      user_principal_name = "admin-user@taustinbennettgmail.onmicrosoft.com"
      display_name        = "Admin User"
      mail_nickname       = "adminuser"
      password            = var.default_user_password
    }
    dev-user = {
      user_principal_name = "dev-user@taustinbennettgmail.onmicrosoft.com"
      display_name        = "Dev User"
      mail_nickname       = "devuser"
      password            = var.default_user_password
    }
    readonly-user = {
      user_principal_name = "readonly-user@taustinbennettgmail.onmicrosoft.com"
      display_name        = "Readonly User"
      mail_nickname       = "readonlyuser"
      password            = var.default_user_password
    }
  }
}