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
    apt-get install -y curl unzip
    snap install aws-cli --classic


# Retrieve secrets from AWS Systems Manager Parameter Store
JWT_SECRET=$(aws ssm get-parameter \
  --name "/app/prod/jwt_secret" \
  --with-decryption \
  --query "Parameter.Value" \
  --output text \
  --region eu-north-1)

MONGO_URI=$(aws ssm get-parameter \
  --name "/app/prod/mongo_uri" \
  --with-decryption \
  --query "Parameter.Value" \
  --output text \
  --region eu-north-1)

# Export as environment variables
export JWT_SECRET=$JWT_SECRET
export MONGO_URI=$MONGO_URI

# Install and configure services
apt-get install -y nginx docker.io
systemctl start nginx
systemctl enable nginx
systemctl start docker
systemctl enable docker

# Install Docker Compose
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Create default web page
echo "Hello from Auto Scaling EC2" > /var/www/html/index.html
  EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "autoscaling-app"
    }
  }

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_instance_profile.name
  }
}