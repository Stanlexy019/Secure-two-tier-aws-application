# Restrict the default security group to deny all traffic
resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.terraform_vpc.id

  # Remove all ingress rules (deny all inbound)
  ingress = []

  # Remove all egress rules (deny all outbound)
  egress = []

  tags = {
    Name = "${var.terraform_vpc}-default-sg-restricted"
  }
}