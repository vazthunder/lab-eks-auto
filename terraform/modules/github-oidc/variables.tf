variable "repository" {
  type        = string
  description = "GitHub repository in owner/repo format for OIDC trust"
}

variable "name_prefix" {
  type        = string
  description = "Prefix for resource names"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags to apply to resources"
}
