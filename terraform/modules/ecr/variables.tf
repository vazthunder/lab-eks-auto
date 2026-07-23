variable "repository_name" {
  type        = string
  description = "ECR repository name"
}

variable "force_delete" {
  type        = bool
  description = "Allow deletion of repository even if it contains images"
  default     = true
}

variable "image_scan_on_push" {
  type        = bool
  description = "Scan images on push for vulnerabilities"
  default     = true
}

variable "image_tag_mutability" {
  type        = string
  description = "Image tag mutability (MUTABLE or IMMUTABLE)"
  default     = "MUTABLE"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags to apply to resources"
}
