variable "location" {
  type        = string
  description = "Azure region for hosting all resources."
  default     = "East US 2"
}

variable "environment" {
  type        = string
  description = "The environment tag for resources in this project."
  default     = "testing"
}

variable "project_name" {
  type        = string
  description = "The name of the current project."
  default     = "test-project"
}

variable "practice_user_upn" {
  type        = string
  description = "The UPN of the user for testing purposes."
}