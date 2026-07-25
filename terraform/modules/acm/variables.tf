variable "domain_names" {
  type        = list(string)
  description = "Domain names for ACM certificate"
}

variable "route53_zone_name" {
  type        = string
  default     = null
  description = "Route53 zone name for auto DNS validation (null = manual)"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags to apply to resources"
}
