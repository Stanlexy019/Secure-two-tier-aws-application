resource "aws_security_group" "app_sg" {
  name        = "${var.terraform_vpc}-app-sg"
  description = "Allow traffic from ALB only"
  vpc_id      = aws_vpc.terraform_vpc.id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.terraform_vpc}-app-sg"
  }
}
