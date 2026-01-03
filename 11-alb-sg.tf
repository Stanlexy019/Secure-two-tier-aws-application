resource "aws_security_group" "alb_sg" {
  name        = "${var.terraform_vpc}-alb-sg"
  description = "Allow HTTP and HTTPS traffic from the internet"
  vpc_id      = aws_vpc.terraform_vpc.id

  # HTTP access (will redirect to HTTPS)
  ingress {
    description = "HTTP access from internet for ALB"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS access
  ingress {
    description = "HTTPS access from internet for ALB"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Egress rules defined separately in 27-security-group-rules.tf to avoid cycles

  tags = {
    Name = "${var.terraform_vpc}-alb-sg"
  }
}
