# Security group rules to avoid circular dependencies

# ALB egress rules
resource "aws_security_group_rule" "alb_egress_http" {
  type                     = "egress"
  description              = "HTTP to application servers"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.app_sg.id
  security_group_id        = aws_security_group.alb_sg.id
}

# App egress rules
resource "aws_security_group_rule" "app_egress_http" {
  type              = "egress"
  description       = "HTTP outbound for updates"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.app_sg.id
}

resource "aws_security_group_rule" "app_egress_https" {
  type              = "egress"
  description       = "HTTPS outbound for updates"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.app_sg.id
}

resource "aws_security_group_rule" "app_egress_mysql" {
  type                     = "egress"
  description              = "MySQL to RDS"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.db_sg.id
  security_group_id        = aws_security_group.app_sg.id
}