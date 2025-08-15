# S3 Bucket
resource "aws_s3_bucket" "main" {
  bucket = var.bucket_name

  tags = {
    Name = var.bucket_name
  }
}

# S3 Bucket Versioning
resource "aws_s3_bucket_versioning" "main" {
  bucket = aws_s3_bucket.main.id
  versioning_configuration {
    status = "Enabled"
  }
}

# S3 Bucket Server Side Encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "main" {
  bucket = aws_s3_bucket.main.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# S3 Bucket Public Access Block
resource "aws_s3_bucket_public_access_block" "main" {
  bucket = aws_s3_bucket.main.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# S3 Bucket Lifecycle Configuration
resource "aws_s3_bucket_lifecycle_configuration" "main" {
  bucket = aws_s3_bucket.main.id

  rule {
    id     = "versioning"
    status = "Enabled"

    filter {
      prefix = ""
    }

    noncurrent_version_expiration {
      noncurrent_days = 30
    }
  }
}

# Create app directory structure
resource "aws_s3_object" "app_directory" {
  bucket = aws_s3_bucket.main.id
  key    = "app/"
}

# Create images directory structure
resource "aws_s3_object" "images_directory" {
  bucket = aws_s3_bucket.main.id
  key    = "images/"
}

# Upload Green binary
resource "aws_s3_object" "green_binary" {
  bucket = aws_s3_bucket.main.id
  key    = "images/green_1.0.1"
  source = "${path.module}/../../0_provided_files/green_1.0.1"
  etag   = filemd5("${path.module}/../../0_provided_files/green_1.0.1")
}

# Upload Red binary
resource "aws_s3_object" "red_binary" {
  bucket = aws_s3_bucket.main.id
  key    = "images/red_1.0.1"
  source = "${path.module}/../../0_provided_files/red_1.0.1"
  etag   = filemd5("${path.module}/../../0_provided_files/red_1.0.1")
} 