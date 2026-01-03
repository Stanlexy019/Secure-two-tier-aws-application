resource "aws_db_instance" "app_db" {
  identifier = "${var.terraform_vpc}-db"

  engine         = "mysql"
  engine_version = "8.0"
  instance_class = "db.t3.micro"

  allocated_storage = 20
  storage_type      = "gp2"

  db_name  = "appdb"
  username = "admin"
  manage_master_user_password = true
  master_user_secret_kms_key_id = aws_kms_key.db_secret_key.arn

  db_subnet_group_name   = aws_db_subnet_group.db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.db_sg.id]

  publicly_accessible = false
  multi_az            = true  # Force Multi-AZ for production security

  # Backup configuration
  backup_retention_period = 7
  backup_window          = "03:00-04:00"
  maintenance_window     = "sun:04:00-sun:05:00"

  # Snapshot configuration
  skip_final_snapshot       = false
  final_snapshot_identifier = "${var.terraform_vpc}-db-final-snapshot-${formatdate("YYYY-MM-DD-hhmm", timestamp())}"

  # Encryption at rest
  storage_encrypted = true
  kms_key_id       = aws_kms_key.db_secret_key.arn

  # Enhanced monitoring
  monitoring_interval = 60
  monitoring_role_arn = aws_iam_role.rds_monitoring_role.arn

  # Performance insights with KMS encryption
  performance_insights_enabled          = true
  performance_insights_retention_period = 7
  performance_insights_kms_key_id       = aws_kms_key.db_secret_key.arn

  # Copy tags to snapshots
  copy_tags_to_snapshot = true

  # Deletion protection for production
  deletion_protection = true

  # Enable IAM database authentication
  iam_database_authentication_enabled = true

  # Enable automated minor version upgrades
  auto_minor_version_upgrade = true

  # Enable RDS logs (MySQL specific log types)
  enabled_cloudwatch_logs_exports = ["error", "general", "slowquery"]

  # Note: multi_az is already set above via variable

  tags = {
    Name        = "${var.terraform_vpc}-db"
    Environment = "production"
    Backup      = "enabled"
    Encrypted   = "true"
  }
}
