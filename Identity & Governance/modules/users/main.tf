resource "azuread_user" "this" {
  # creates a user for each entry in the users map variable
  for_each = var.users

  user_principal_name = each.value.user_principal_name
  display_name        = each.value.display_name
  mail_nickname       = each.value.mail_nickname
  password            = each.value.password
}