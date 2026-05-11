# ==============================================================================
# 1. НАЗВА ДЛЯ S3 БАКЕТА (робимо її унікальною)
# ==============================================================================
module "website_label" {
  source    = "cloudposse/label/null"
  version   = "0.25.0"
  namespace = "uni"
  stage     = "dev"
  name      = "courses-frontend"
}

# ==============================================================================
# 2. СТВОРЕННЯ S3 БАКЕТА
# ==============================================================================
resource "aws_s3_bucket" "frontend" {
  bucket        = module.website_label.id
  force_destroy = true # Щоб Terraform міг легко видалити бакет у майбутньому
}

# Налаштування бакета як веб-сайту (Static Website Hosting)
resource "aws_s3_bucket_website_configuration" "frontend_hosting" {
  bucket = aws_s3_bucket.frontend.id

  index_document {
    suffix = "index.html"
  }
  error_document {
    key = "index.html" # КРИТИЧНО ДЛЯ REACT: всі помилки 404 йдуть на index.html
  }
}

# ==============================================================================
# 3. ПОЛІТИКИ ДОСТУПУ (РОБИМО САЙТ ПУБЛІЧНИМ)
# ==============================================================================
# Спочатку знімаємо блокування публічного доступу
resource "aws_s3_bucket_public_access_block" "unblock_public_access" {
  bucket = aws_s3_bucket.frontend.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# Додаємо Bucket Policy, що дозволяє всім читати файли (s3:GetObject)
resource "aws_s3_bucket_policy" "public_read_policy" {
  bucket = aws_s3_bucket.frontend.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.frontend.arn}/*"
      }
    ]
  })
  
  # Політика застосується ТІЛЬКИ після зняття блокування
  depends_on = [aws_s3_bucket_public_access_block.unblock_public_access]
}

# ==============================================================================
# 4. CLOUDFRONT (ГЛОБАЛЬНИЙ CDN)
# ==============================================================================
resource "aws_cloudfront_distribution" "cdn" {
  origin {
    # Вказуємо веб-ендпоінт S3 як джерело
    domain_name = aws_s3_bucket_website_configuration.frontend_hosting.website_endpoint
    origin_id   = "S3-${aws_s3_bucket.frontend.bucket}"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-${aws_s3_bucket.frontend.bucket}"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = "none" # Без блокувань по країнах
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

# ==============================================================================
# 5. ВИВІД ДАНИХ У КОНСОЛЬ (Щоб ми знали, куди заливати файли)
# ==============================================================================
output "s3_bucket_name" {
  value = aws_s3_bucket.frontend.id
}

output "cloudfront_domain_url" {
  value = "https://${aws_cloudfront_distribution.cdn.domain_name}"
}