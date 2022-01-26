### Route53 DNS config and ACM certificate creation to enable access via domain over SSL

# Looks up the public DNS zone, which is assumed to have been already created manually in Route53
data "aws_route53_zone" "app_domain" {
  name         = var.app_domain
  private_zone = false
}

# Create ACM certificate for this domain
resource "aws_acm_certificate" "app" {
  domain_name       = var.app_domain
  validation_method = "DNS"
  lifecycle {
    create_before_destroy = true
  }
}

# Create DNS record for the ACM cert validation to prove we own the domain
resource "aws_route53_record" "cert_validation" {
  allow_overwrite = true
  name            = tolist(aws_acm_certificate.app.domain_validation_options)[0].resource_record_name
  records         = [tolist(aws_acm_certificate.app.domain_validation_options)[0].resource_record_value]
  type            = tolist(aws_acm_certificate.app.domain_validation_options)[0].resource_record_type
  zone_id         = data.aws_route53_zone.app_domain.id
  ttl             = 60
}

# Trigger the ACM certificate validation
resource "aws_acm_certificate_validation" "cert" {
  certificate_arn         = aws_acm_certificate.app.arn
  validation_record_fqdns = [aws_route53_record.cert_validation.fqdn]
}

output "app_domain_acm_certificate_arn" {
  value = aws_acm_certificate.app.arn
}

output "app_domain_route53_zone_id" {
  value = data.aws_route53_zone.app_domain.zone_id
}
