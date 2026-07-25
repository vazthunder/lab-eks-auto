output "certificate_arn" {
  value = aws_acm_certificate.main.arn
}

output "validation_options" {
  description = "CNAME records needed for DNS validation (for manual setup)"
  value = var.route53_zone_name == null ? [
    for dvo in aws_acm_certificate.main.domain_validation_options : {
      name  = dvo.resource_record_name
      type  = dvo.resource_record_type
      value = dvo.resource_record_value
    }
  ] : null
}

output "validated_certificate_arn" {
  description = "ARN after validation (only if auto-validated)"
  value       = var.route53_zone_name != null ? aws_acm_certificate_validation.main[0].certificate_arn : null
}
