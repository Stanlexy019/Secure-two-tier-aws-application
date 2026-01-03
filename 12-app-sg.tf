resource "aws_security_group" "app_sg" {
  name        = "${var.terraform_vpc}-app-sg"
  description = "Allow traffic from ALB only"
  vpc_id      = aws_vpc.terraform_vpc.id

  ingress {
    description     = "HTTP access from ALB only"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  # Egress rules defined separately in 27-security-group-rules.tf to avoid cycles

  tags = {
    Name = "${var.terraform_vpc}-app-sg"
  }
}
