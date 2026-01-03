# Data source to get current AWS account ID
data "aws_caller_identity" "current" {}

# KMS key for encrypting database secrets
resource "aws_kms_key" "db_secret_key" {
  description             = "KMS key for RDS database secrets encryption"
  deletion_window_in_days = 10
  enable_key_rotation     = true

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "Allow RDS and Secrets Manager to use the key"
        Effect = "Allow"
        Principal = {
          Service = [
            "rds.amazonaws.com",
            "secretsmanager.amazonaws.com"
          ]
        }
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey"
        ]
        Resource = "*"
      }
    ]
  })

  tags = {
    Name = "${var.terraform_vpc}-db-secret-key"
  }
}

resource "aws_kms_alias" "db_secret_key_alias" {
  name          = "alias/${var.terraform_vpc}-db-secret-key"
  target_key_id = aws_kms_key.db_secret_key.key_id
}

# IAM role for RDS enhanced monitoring
resource "aws_iam_role" "rds_monitoring_role" {
  name = "${var.terraform_vpc}-rds-monitoring-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "monitoring.rds.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "${var.terraform_vpc}-rds-monitoring-role"
  }
}

resource "aws_iam_role_policy_attachment" "rds_monitoring_policy" {
  role       = aws_iam_role.rds_monitoring_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}