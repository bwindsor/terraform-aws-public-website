locals {
  s3_origin_id = "${var.deployment_name}-S3-website"
}

resource "aws_cloudfront_origin_access_identity" "main" {
  comment = "Created for ${var.deployment_name}"
}

resource "aws_cloudfront_distribution" "s3_distribution" {
  tags = {
    Name = "${var.deployment_name}-website"
  }
  origin {
    domain_name = aws_s3_bucket.website.bucket_regional_domain_name
    origin_id   = local.s3_origin_id
    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.main.cloudfront_access_identity_path
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods = ["HEAD", "DELETE", "POST", "GET", "OPTIONS", "PUT", "PATCH"]
    cached_methods  = ["GET", "HEAD"]
    forwarded_values {
      cookies {
        forward = "none"
      }
      query_string = false
    }
    target_origin_id       = local.s3_origin_id
    viewer_protocol_policy = "redirect-to-https"
    # Set caching to 30 seconds for quick updates
    min_ttl          = 30
    default_ttl      = 30
    max_ttl          = 30
    smooth_streaming = false

    lambda_function_association {
      event_type   = "origin-response"
      lambda_arn   = aws_lambda_function.lambda_add_security_headers.qualified_arn
      include_body = false
    }
  }

  price_class = "PriceClass_100"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  aliases = [var.custom_domain]

  viewer_certificate {
    acm_certificate_arn = aws_acm_certificate_validation.main_website_cert.certificate_arn
    ssl_support_method  = "sni-only"
  }

  # Custom error response to make SPA work, always return index.html for all routes
  dynamic "custom_error_response" {
    for_each = var.is_spa ? [0] : []
    content {
      error_code            = 404
      error_caching_min_ttl = 0
      response_page_path    = "/index.html"
      response_code         = 200
    }
  }

  wait_for_deployment = false
}


resource "aws_cloudfront_distribution" "alternative_domain_distributions" {
  for_each = var.alternative_custom_domains

  tags = {
    Name = "${var.deployment_name}-website-alternative-${each.value}"
  }
  origin {
    domain_name = aws_s3_bucket.website_alternative_redirect[each.value].website_endpoint
    origin_id   = local.s3_origin_id
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1"]
    }
  }

  enabled         = true
  is_ipv6_enabled = true

  default_cache_behavior {
    allowed_methods = ["HEAD", "DELETE", "POST", "GET", "OPTIONS", "PUT", "PATCH"]
    cached_methods  = ["GET", "HEAD"]
    forwarded_values {
      cookies {
        forward = "none"
      }
      query_string = false
    }
    target_origin_id       = local.s3_origin_id
    viewer_protocol_policy = "redirect-to-https"
    # Set caching to 30 seconds for quick updates
    min_ttl          = 30
    default_ttl      = 30
    max_ttl          = 30
    smooth_streaming = false
  }

  price_class = "PriceClass_100"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  aliases = [each.value]

  viewer_certificate {
    acm_certificate_arn = aws_acm_certificate_validation.main_website_cert.certificate_arn
    ssl_support_method  = "sni-only"
  }

  wait_for_deployment = false
}
