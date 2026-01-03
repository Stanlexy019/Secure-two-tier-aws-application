# Infrastructure outputs for reference and integration
output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.terraform_vpc.id
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.terraform_vpc.cidr_block
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id]
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id]
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.app_alb.dns_name
}

output "alb_zone_id" {
  description = "Zone ID of the Application Load Balancer"
  value       = aws_lb.app_alb.zone_id
}

output "alb_arn" {
  description = "ARN of the Application Load Balancer"
  value       = aws_lb.app_alb.arn
}

output "rds_endpoint" {
  description = "RDS instance endpoint"
  value       = aws_db_instance.app_db.endpoint
  sensitive   = true
}

output "rds_port" {
  description = "RDS instance port"
  value       = aws_db_instance.app_db.port
}

output "auto_scaling_group_arn" {
  description = "ARN of the Auto Scaling Group"
  value       = aws_autoscaling_group.app_asg.arn
}

output "ssl_certificate_arn" {
  description = "ARN of the SSL certificate"
  value       = aws_acm_certificate.app_cert.arn
}

# Security group IDs for reference
output "security_group_ids" {
  description = "Map of security group names to IDs"
  value = {
    alb = aws_security_group.alb_sg.id
    app = aws_security_group.app_sg.id
    db  = aws_security_group.db_sg.id
  }
}

# NAT Gateway information
output "nat_gateway_id" {
  description = "ID of the NAT Gateway"
  value       = aws_nat_gateway.nat_gw.id
}

output "elastic_ip" {
  description = "Elastic IP address of the NAT Gateway"
  value       = aws_eip.nat_eip.public_ip
}