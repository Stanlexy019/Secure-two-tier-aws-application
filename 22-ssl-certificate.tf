# SSL Certificate for HTTPS
resource "aws_acm_certificate" "app_cert" {
  domain_name       = var.domain_name
  validation_method = "DNS"

  subject_alternative_names = [
    "*.${var.domain_name}"
  ]

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "${var.terraform_vpc}-ssl-cert"
  }
}

# Certificate validation (requires domain ownership)
resource "aws_acm_certificate_validation" "app_cert" {
  certificate_arn = aws_acm_certificate.app_cert.arn
  validation_record_fqdns = [
    for record in aws_acm_certificate.app_cert.domain_validation_options : record.resource_record_name
  ]

  timeouts {
    create = "5m"
  }
}