variable "repository" {
  type        = string
  description = "GitHub repository in owner/repo format for OIDC trust"
}

variable "name_prefix" {
  type        = string
  description = "Prefix for resource names"
}

variable "sub_claim" {
  type        = string
  description = "GitHub OIDC sub claim pattern (e.g. repo:owner/repo:*)"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags to apply to resources"
}
