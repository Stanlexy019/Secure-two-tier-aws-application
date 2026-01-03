# S3 bucket for ALB access logs
resource "aws_s3_bucket" "alb_logs" {
  bucket        = "${var.terraform_vpc}-alb-logs-${random_string.bucket_suffix.result}"
  force_destroy = false

  tags = {
    Name        = "${var.terraform_vpc}-alb-logs"
    Environment = "production"
  }
}

# Random string for unique bucket naming
resource "random_string" "bucket_suffix" {
  length  = 8
  special = false
  upper   = false
}

# S3 bucket versioning
resource "aws_s3_bucket_versioning" "alb_logs" {
  bucket = aws_s3_bucket.alb_logs.id
  versioning_configuration {
    status = "Enabled"
  }
}

# S3 bucket server-side encryption with KMS
resource "aws_s3_bucket_server_side_encryption_configuration" "alb_logs" {
  bucket = aws_s3_bucket.alb_logs.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.db_secret_key.arn
    }
    bucket_key_enabled = true
  }
}

# S3 bucket public access block
resource "aws_s3_bucket_public_access_block" "alb_logs" {
  bucket = aws_s3_bucket.alb_logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# S3 bucket policy for ALB access logs
data "aws_elb_service_account" "main" {}

resource "aws_s3_bucket_policy" "alb_logs" {
  bucket = aws_s3_bucket.alb_logs.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = data.aws_elb_service_account.main.arn
        }
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.alb_logs.arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"
      },
      {
        Effect = "Allow"
        Principal = {
          Service = "delivery.logs.amazonaws.com"
        }
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.alb_logs.arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
      },
      {
        Effect = "Allow"
        Principal = {
          Service = "delivery.logs.amazonaws.com"
        }
        Action   = "s3:GetBucketAcl"
        Resource = aws_s3_bucket.alb_logs.arn
      }
    ]
  })
}

# S3 bucket lifecycle configuration
resource "aws_s3_bucket_lifecycle_configuration" "alb_logs" {
  bucket = aws_s3_bucket.alb_logs.id

  rule {
    id     = "log_retention"
    status = "Enabled"

    # Abort incomplete multipart uploads after 1 day
    abort_incomplete_multipart_upload {
      days_after_initiation = 1
    }

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 90
      storage_class = "GLACIER"
    }

    expiration {
      days = 365
    }
  }
}

# S3 bucket logging for access logs
resource "aws_s3_bucket_logging" "alb_logs" {
  bucket = aws_s3_bucket.alb_logs.id

  target_bucket = aws_s3_bucket.alb_access_logs.id
  target_prefix = "access-logs/"
}

# Separate bucket for S3 access logs
resource "aws_s3_bucket" "alb_access_logs" {
  bucket        = "${var.terraform_vpc}-s3-access-logs-${random_string.bucket_suffix.result}"
  force_destroy = false

  tags = {
    Name        = "${var.terraform_vpc}-s3-access-logs"
    Environment = "production"
  }
}

# S3 bucket versioning for access logs bucket
resource "aws_s3_bucket_versioning" "alb_access_logs" {
  bucket = aws_s3_bucket.alb_access_logs.id
  versioning_configuration {
    status = "Enabled"
  }
}

# S3 bucket encryption for access logs bucket
resource "aws_s3_bucket_server_side_encryption_configuration" "alb_access_logs" {
  bucket = aws_s3_bucket.alb_access_logs.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.db_secret_key.arn
    }
    bucket_key_enabled = true
  }
}

# S3 bucket public access block for access logs bucket
resource "aws_s3_bucket_public_access_block" "alb_access_logs" {
  bucket = aws_s3_bucket.alb_access_logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# S3 bucket notification for EventBridge
resource "aws_s3_bucket_notification" "alb_logs_notification" {
  bucket = aws_s3_bucket.alb_logs.id

  eventbridge = true
}

# Cross-region replication for main ALB logs bucket
resource "aws_s3_bucket_replication_configuration" "alb_logs_replication" {
  role   = aws_iam_role.s3_replication_role.arn
  bucket = aws_s3_bucket.alb_logs.id

  status = "Enabled"

  rule {
    id     = "replicate-alb-logs"
    status = "Enabled"

    destination {
      bucket        = aws_s3_bucket.alb_logs_replica.arn
      storage_class = "STANDARD_IA"

      encryption_configuration {
        replica_kms_key_id = aws_kms_key.db_secret_key.arn
      }
    }
  }

  depends_on = [aws_s3_bucket_versioning.alb_logs]
}

# Replica bucket in different region (simulated with different name)
resource "aws_s3_bucket" "alb_logs_replica" {
  bucket        = "${var.terraform_vpc}-alb-logs-replica-${random_string.bucket_suffix.result}"
  force_destroy = false

  tags = {
    Name        = "${var.terraform_vpc}-alb-logs-replica"
    Environment = "production"
    Type        = "replica"
  }
}

# Versioning for replica bucket
resource "aws_s3_bucket_versioning" "alb_logs_replica" {
  bucket = aws_s3_bucket.alb_logs_replica.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Encryption for replica bucket
resource "aws_s3_bucket_server_side_encryption_configuration" "alb_logs_replica" {
  bucket = aws_s3_bucket.alb_logs_replica.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.db_secret_key.arn
    }
    bucket_key_enabled = true
  }
}

# Public access block for replica bucket
resource "aws_s3_bucket_public_access_block" "alb_logs_replica" {
  bucket = aws_s3_bucket.alb_logs_replica.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Cross-region replication for access logs bucket
resource "aws_s3_bucket_replication_configuration" "alb_access_logs_replication" {
  role   = aws_iam_role.s3_replication_role.arn
  bucket = aws_s3_bucket.alb_access_logs.id

  status = "Enabled"

  rule {
    id     = "replicate-access-logs"
    status = "Enabled"

    destination {
      bucket        = aws_s3_bucket.alb_access_logs_replica.arn
      storage_class = "STANDARD_IA"

      encryption_configuration {
        replica_kms_key_id = aws_kms_key.db_secret_key.arn
      }
    }
  }

  depends_on = [aws_s3_bucket_versioning.alb_access_logs]
}

# Replica bucket for access logs
resource "aws_s3_bucket" "alb_access_logs_replica" {
  bucket        = "${var.terraform_vpc}-access-logs-replica-${random_string.bucket_suffix.result}"
  force_destroy = false

  tags = {
    Name        = "${var.terraform_vpc}-access-logs-replica"
    Environment = "production"
    Type        = "replica"
  }
}

# Versioning for access logs replica
resource "aws_s3_bucket_versioning" "alb_access_logs_replica" {
  bucket = aws_s3_bucket.alb_access_logs_replica.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Encryption for access logs replica
resource "aws_s3_bucket_server_side_encryption_configuration" "alb_access_logs_replica" {
  bucket = aws_s3_bucket.alb_access_logs_replica.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.db_secret_key.arn
    }
    bucket_key_enabled = true
  }
}

# Public access block for access logs replica
resource "aws_s3_bucket_public_access_block" "alb_access_logs_replica" {
  bucket = aws_s3_bucket.alb_access_logs_replica.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Lifecycle configuration for access logs bucket
resource "aws_s3_bucket_lifecycle_configuration" "alb_access_logs" {
  bucket = aws_s3_bucket.alb_access_logs.id

  rule {
    id     = "access_log_retention"
    status = "Enabled"

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 90
      storage_class = "GLACIER"
    }

    expiration {
      days = 365
    }
  }
}

# Event notification for access logs bucket
resource "aws_s3_bucket_notification" "alb_access_logs_notification" {
  bucket = aws_s3_bucket.alb_access_logs.id

  eventbridge = true
}

# IAM role for S3 replication
resource "aws_iam_role" "s3_replication_role" {
  name = "${var.terraform_vpc}-s3-replication-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "s3.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "${var.terraform_vpc}-s3-replication-role"
  }
}

# IAM policy for S3 replication
resource "aws_iam_role_policy" "s3_replication_policy" {
  name = "${var.terraform_vpc}-s3-replication-policy"
  role = aws_iam_role.s3_replication_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObjectVersionForReplication",
          "s3:GetObjectVersionAcl"
        ]
        Resource = [
          "${aws_s3_bucket.alb_logs.arn}/*",
          "${aws_s3_bucket.alb_access_logs.arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.alb_logs.arn,
          aws_s3_bucket.alb_access_logs.arn
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "s3:ReplicateObject",
          "s3:ReplicateDelete"
        ]
        Resource = [
          "${aws_s3_bucket.alb_logs_replica.arn}/*",
          "${aws_s3_bucket.alb_access_logs_replica.arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey"
        ]
        Resource = aws_kms_key.db_secret_key.arn
      }
    ]
  })
}