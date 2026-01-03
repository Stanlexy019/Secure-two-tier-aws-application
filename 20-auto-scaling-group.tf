resource "aws_autoscaling_group" "app_asg" {
  name = "app-asg"

  min_size         = 1
  max_size         = 3
  desired_capacity = 2

  vpc_zone_identifier = [
    aws_subnet.private_subnet_1.id,
    aws_subnet.private_subnet_2.id
  ]

  target_group_arns   = [aws_lb_target_group.app_tg.arn]
  health_check_type   = "ELB"
  health_check_grace_period = 300

  # Enable instance protection from scale-in
  protect_from_scale_in = false

  # Wait for minimum healthy capacity during updates
  wait_for_capacity_timeout = "10m"
  min_elb_capacity         = 1

  launch_template {
    id      = aws_launch_template.app_lt.id
    version = "$Latest"
  }

  # Spread instances across availability zones
  availability_zones = [
    "${var.region}a",
    "${var.region}b"
  ]

  tag {
    key                 = "Name"
    value               = "autoscaling-app"
    propagate_at_launch = true
  }

  tag {
    key                 = "Environment"
    value               = "production"
    propagate_at_launch = true
  }

  tag {
    key                 = "AutoScaling"
    value               = "enabled"
    propagate_at_launch = false
  }
}
