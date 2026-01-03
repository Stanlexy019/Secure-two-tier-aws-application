# Data source to get latest Ubuntu AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_launch_template" "app_lt" {
  name_prefix   = "app-lt-"
  image_id      = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"

  vpc_security_group_ids = [
    aws_security_group.app_sg.id
  ]

  user_data = base64encode(<<-EOF
    #!/bin/bash
    apt-get update -y
    apt-get install -y nginx
    systemctl start nginx
    systemctl enable nginx
    echo "Hello from Auto Scaling EC2" > /var/www/html/index.html
  EOF
  )

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "autoscaling-app"
    }
  }
}
