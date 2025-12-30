resource "aws_instance" "app_server" {
  ami           = "ami-0fa91bc90632c73c9" # Ubuntu 24.04 (eu-north-1)
  instance_type = "t3.micro"

  subnet_id = aws_subnet.private_subnet_1.id

  vpc_security_group_ids = [
    aws_security_group.app_sg.id
  ]

  user_data = <<-EOF
              #!/bin/bash
              apt-get update -y
              apt-get upgrade -y
              apt-get install -y nginx
              systemctl start nginx
              systemctl enable nginx
              echo "Hello from private EC2" > /var/www/html/index.html
              EOF

  tags = {
    Name = "${var.terraform_vpc}-app-server"
  }
}
