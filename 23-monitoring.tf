# CloudWatch Log Group for ALB access logs
resource "aws_cloudwatch_log_group" "alb_logs" {
  name              = "/aws/alb/${var.terraform_vpc}"
  retention_in_days = 365
  kms_key_id        = aws_kms_key.db_secret_key.arn

  tags = {
    Name        = "${var.terraform_vpc}-alb-logs"
    Environment = "production"
  }
}

# CloudWatch Log Group for application logs
resource "aws_cloudwatch_log_group" "app_logs" {
  name              = "/aws/ec2/${var.terraform_vpc}"
  retention_in_days = 365
  kms_key_id        = aws_kms_key.db_secret_key.arn

  tags = {
    Name        = "${var.terraform_vpc}-app-logs"
    Environment = "production"
  }
}

# CloudWatch Alarm for high CPU usage on Auto Scaling Group
resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name          = "${var.terraform_vpc}-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "70"
  alarm_description   = "This metric monitors ec2 cpu utilization"
  alarm_actions       = [aws_sns_topic.alerts.arn]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.app_asg.name
  }

  tags = {
    Name        = "${var.terraform_vpc}-high-cpu-alarm"
    Environment = "production"
  }
}

# CloudWatch Alarm for RDS CPU usage
resource "aws_cloudwatch_metric_alarm" "rds_high_cpu" {
  alarm_name          = "${var.terraform_vpc}-rds-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = "120"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "This metric monitors RDS CPU utilization"
  alarm_actions       = [aws_sns_topic.alerts.arn]

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.app_db.id
  }

  tags = {
    Name        = "${var.terraform_vpc}-rds-high-cpu-alarm"
    Environment = "production"
  }
}

# CloudWatch Alarm for ALB target health
resource "aws_cloudwatch_metric_alarm" "alb_unhealthy_hosts" {
  alarm_name          = "${var.terraform_vpc}-alb-unhealthy-hosts"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "HealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  period              = "60"
  statistic           = "Average"
  threshold           = "1"
  alarm_description   = "This metric monitors ALB healthy host count"
  alarm_actions       = [aws_sns_topic.alerts.arn]
  treat_missing_data  = "breaching"

  dimensions = {
    TargetGroup  = aws_lb_target_group.app_tg.arn_suffix
    LoadBalancer = aws_lb.app_alb.arn_suffix
  }

  tags = {
    Name        = "${var.terraform_vpc}-alb-unhealthy-hosts-alarm"
    Environment = "production"
  }
}

# SNS Topic for alerts
resource "aws_sns_topic" "alerts" {
  name              = "${var.terraform_vpc}-alerts"
  kms_master_key_id = aws_kms_key.db_secret_key.arn

  tags = {
    Name        = "${var.terraform_vpc}-alerts"
    Environment = "production"
  }
}

# VPC Flow Logs for network monitoring
resource "aws_flow_log" "vpc_flow_log" {
  iam_role_arn    = aws_iam_role.vpc_flow_log_role.arn
  log_destination = aws_cloudwatch_log_group.vpc_flow_logs.arn
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.terraform_vpc.id

  tags = {
    Name        = "${var.terraform_vpc}-flow-logs"
    Environment = "production"
  }
}

resource "aws_cloudwatch_log_group" "vpc_flow_logs" {
  name              = "/aws/vpc/${var.terraform_vpc}/flowlogs"
  retention_in_days = 365
  kms_key_id        = aws_kms_key.db_secret_key.arn

  tags = {
    Name        = "${var.terraform_vpc}-vpc-flow-logs"
    Environment = "production"
  }
}

# IAM role for VPC Flow Logs
resource "aws_iam_role" "vpc_flow_log_role" {
  name = "${var.terraform_vpc}-vpc-flow-log-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "vpc-flow-logs.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "${var.terraform_vpc}-vpc-flow-log-role"
  }
}

resource "aws_iam_role_policy" "vpc_flow_log_policy" {
  name = "${var.terraform_vpc}-vpc-flow-log-policy"
  role = aws_iam_role.vpc_flow_log_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ]
        Effect = "Allow"
        Resource = [
          aws_cloudwatch_log_group.vpc_flow_logs.arn,
          "${aws_cloudwatch_log_group.vpc_flow_logs.arn}:*"
        ]
      }
    ]
  })
}