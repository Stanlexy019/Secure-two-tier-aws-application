resource "aws_security_group" "db_sg" {
  name        = "${var.terraform_vpc}-db-sg"
  description = "Allow DB traffic from App only"
  vpc_id      = aws_vpc.terraform_vpc.id

  ingress {
    description     = "MySQL access from application servers only"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.app_sg.id]
  }

  # No egress rules needed for RDS (AWS managed service)

  tags = {
    Name = "${var.terraform_vpc}-db-sg"
  }
}
