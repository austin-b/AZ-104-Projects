########## STAGE 1 - Create Resource Groups
# prod resource group
resource "azurerm_resource_group" "prod" {
  name     = "rg-prod"
  location = "East US"
}
# dev resource group
resource "azurerm_resource_group" "dev" {
  name     = "rg-dev"
  location = "East US"
}
# staging resource group
resource "azurerm_resource_group" "staging" {
  name     = "rg-staging"
  location = "East US"
}

############ STAGE 2 - Create Users
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

############ STAGE 3 - Create Groups and Assign Users
# Create groups
resource "azuread_group" "admins" {
  display_name     = "Admins"
  security_enabled = true
}
resource "azuread_group" "devs" {
  display_name     = "Developers"
  security_enabled = true
}
resource "azuread_group" "viewers" {
  display_name     = "Viewers"
  security_enabled = true
}
# Add users to groups
resource "azuread_group_member" "admins" {
  group_object_id = azuread_group.admins.object_id
  member_object_id = module.users.user_ids["admin-user"]
}
resource "azuread_group_member" "devs" {
  group_object_id = azuread_group.devs.object_id
  member_object_id = module.users.user_ids["dev-user"]
}
resource "azuread_group_member" "viewers" {
  group_object_id = azuread_group.viewers.object_id
  member_object_id = module.users.user_ids["readonly-user"]
}