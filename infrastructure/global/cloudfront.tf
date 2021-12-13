resource "aws_cloudfront_distribution" "aws_k3s" {
  is_ipv6_enabled = true
  enabled = true
  # aliases = ["cdn-${var.env}-aws-k3s"]

  origin {
    domain_name = data.aws_elb.ms_users_lb.dns_name
    origin_id = "ms-users"
    custom_origin_config {
      http_port = 80
      https_port = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols = ["TLSv1"]
    }
  }

  origin {
    domain_name = data.aws_elb.ms_payments_lb.dns_name
    origin_id = "ms-payments"
    custom_origin_config {
      http_port = 80
      https_port = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols = ["TLSv1"]
    }
  }

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["HEAD", "GET"]
    target_origin_id = "ms-users"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  ordered_cache_behavior {
    path_pattern     = "/api/users*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = "ms-users"

    forwarded_values {
      query_string = false
      headers      = ["Origin"]

      cookies {
        forward = "none"
      }
    }

    min_ttl                = 0
    default_ttl            = 10
    max_ttl                = 10
    compress               = true
    viewer_protocol_policy = "allow-all"
  }

  ordered_cache_behavior {
    path_pattern     = "/api/payments*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = "ms-payments"

    forwarded_values {
      query_string = false
      headers      = ["Origin"]

      cookies {
        forward = "none"
      }
    }

    min_ttl                = 0
    default_ttl            = 10
    max_ttl                = 10
    compress               = true
    viewer_protocol_policy = "allow-all"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate{
    cloudfront_default_certificate = true
  }
}
