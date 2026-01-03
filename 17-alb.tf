resource "aws_lb" "app_alb" {
  name               = "stanley-vpc-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]

  subnets = [
    aws_subnet.public_subnet_1.id,
    aws_subnet.public_subnet_2.id
  ]

  # Enable access logging
  access_logs {
    bucket  = aws_s3_bucket.alb_logs.bucket
    prefix  = "alb-logs"
    enabled = true
  }

  # Enable deletion protection for production
  enable_deletion_protection = true

  # Drop invalid headers
  drop_invalid_header_fields = true

  tags = {
    Name        = "stanley-vpc-alb"
    Environment = "production"
  }
}
