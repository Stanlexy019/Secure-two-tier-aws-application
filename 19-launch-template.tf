resource "aws_launch_template" "app_lt" {
  name_prefix   = "app-lt-"
  image_id      = aws_instance.app_server.ami
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
