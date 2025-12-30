resource "aws_security_group" "db_sg" {
  name        = "${var.terraform_vpc}-db-sg"
  description = "Allow DB traffic from App only"
  vpc_id      = aws_vpc.terraform_vpc.id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.app_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.terraform_vpc}-db-sg"
  }
}
