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

  # Enable detailed monitoring
  monitoring {
    enabled = true
  }

  # Enable EBS optimization
  ebs_optimized = true

  # Block device mapping with encryption
  block_device_mappings {
    device_name = "/dev/sda1"
    ebs {
      volume_size           = 20
      volume_type           = "gp3"
      encrypted             = true
      kms_key_id           = aws_kms_key.db_secret_key.arn
      delete_on_termination = true
    }
  }

  # Disable IMDSv1 and require IMDSv2 for security
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "enabled"
  }

  user_data = base64encode(<<-EOF
    #!/bin/bash
    apt-get update -y
    apt-get install -y nginx awscli
    systemctl start nginx
    systemctl enable nginx

    # Configure nginx with security headers
    cat > /etc/nginx/sites-available/default <<EOL
    server {
        listen 80 default_server;
        listen [::]:80 default_server;

        root /var/www/html;
        index index.html index.htm index.nginx-debian.html;

        server_name _;

        # Security headers
        add_header X-Frame-Options DENY;
        add_header X-Content-Type-Options nosniff;
        add_header X-XSS-Protection "1; mode=block";
        add_header Strict-Transport-Security "max-age=31536000; includeSubDomains";

        location / {
            try_files \$uri \$uri/ =404;
        }

        # Hide nginx version
        server_tokens off;
    }
EOL

    systemctl reload nginx
    echo "<h1>Hello from Auto Scaling EC2</h1><p>Instance ID: \$(curl -s http://169.254.169.254/latest/meta-data/instance-id)</p>" > /var/www/html/index.html
  EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name        = "autoscaling-app"
      Environment = "production"
      Encrypted   = "true"
    }
  }

  tag_specifications {
    resource_type = "volume"
    tags = {
      Name        = "autoscaling-app-volume"
      Environment = "production"
      Encrypted   = "true"
    }
  }
}
