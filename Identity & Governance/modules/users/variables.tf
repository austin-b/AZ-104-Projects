# creating map variable for reusability
variable "users" {
  description = "Map of Entra users keyed by short name"
  type = map(object({
    user_principal_name = string
    display_name        = string
    mail_nickname       = string
    password            = string
  }))
}