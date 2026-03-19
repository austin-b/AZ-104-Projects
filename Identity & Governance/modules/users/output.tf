output "user_ids" {
  value = { for k, u in azuread_user.this : k => u.object_id }
}

output "upns" {
  value = { for k, u in azuread_user.this : k => u.user_principal_name }
}