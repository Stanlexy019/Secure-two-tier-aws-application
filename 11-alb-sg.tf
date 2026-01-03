resource "aws_security_group" "alb_sg" {
  name        = "${var.terraform_vpc}-alb-sg"
  description = "Allow HTTP and HTTPS traffic from the internet"
  vpc_id      = aws_vpc.terraform_vpc.id

  # HTTP access (will redirect to HTTPS)
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS access
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.terraform_vpc}-alb-sg"
  }
}
