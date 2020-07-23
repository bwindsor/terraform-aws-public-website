locals {
  # Hard corded fixed for cloudfront, see https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-properties-route53-aliastarget.html#cfn-route53-aliastarget-hostedzoneid
  AWS_CLOUDFRONT_HOSTED_ZONE_ID = "Z2FDTNDATAQYW2"
  root_pippa_domain       = "mypippa.me"
}

data "aws_route53_zone" "hosted_zone" {
  name         = var.hosted_zone_name
  private_zone = false
}

resource "aws_acm_certificate" "ssl_certificate" {
  domain_name       = var.custom_domain
  subject_alternative_names = var.alternative_custom_domains
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
  tags = {
    Name = var.custom_domain
  }

  provider = aws.protected-website-us-east-1
}

resource "aws_route53_record" "ssl_cert_validation" {
  count = 1 + length(aws_acm_certificate.ssl_certificate.subject_alternative_names)

  name    = aws_acm_certificate.ssl_certificate.domain_validation_options[count.index].resource_record_name
  type    = aws_acm_certificate.ssl_certificate.domain_validation_options[count.index].resource_record_type
  zone_id = data.aws_route53_zone.hosted_zone.id
  records = [aws_acm_certificate.ssl_certificate.domain_validation_options[count.index].resource_record_value]
  ttl     = 60

  provider = aws.protected-website-us-east-1
}

resource "aws_acm_certificate_validation" "main_website_cert" {
  certificate_arn         = aws_acm_certificate.ssl_certificate.arn
  validation_record_fqdns = aws_route53_record.ssl_cert_validation.*.fqdn
  provider                = aws.protected-website-us-east-1
}

resource "aws_route53_record" "main_website_A" {
  name    = aws_acm_certificate.ssl_certificate.domain_name
  type    = "A"
  zone_id = data.aws_route53_zone.hosted_zone.id

  alias {
    evaluate_target_health = true
    name                   = aws_cloudfront_distribution.s3_distribution.domain_name
    zone_id                = local.AWS_CLOUDFRONT_HOSTED_ZONE_ID
  }
}
resource "aws_route53_record" "main_website_alternatives" {
  count = length(aws_acm_certificate.ssl_certificate.subject_alternative_names)

  name    = aws_acm_certificate.ssl_certificate.subject_alternative_names[count.index]
  type    = "A"
  zone_id = data.aws_route53_zone.hosted_zone.id

  alias {
    evaluate_target_health = true
    name                   = aws_cloudfront_distribution.alternative_domain_distributions[count.index].domain_name
    zone_id                = local.AWS_CLOUDFRONT_HOSTED_ZONE_ID
  }
}
