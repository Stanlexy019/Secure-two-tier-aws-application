variable "region" {
  description = "AWS region"
  type        = string
  default     = "eu-north-1"
}

variable "terraform_vpc" {
  default = "stanlexy-vpc"
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "The vpc_cidr value must be a valid CIDR block."
  }
}

variable "domain_name" {
  description = "Domain name for SSL certificate (required for HTTPS)"
  type        = string
  default     = "example.com"

  validation {
    condition     = can(regex("^[a-z0-9-]+(\\.[a-z0-9-]+)+$", var.domain_name))
    error_message = "Domain name must be a valid domain format."
  }
}

variable "enable_multi_az_nat" {
  description = "Enable NAT Gateway in multiple availability zones for high availability"
  type        = bool
  default     = false
}

variable "enable_rds_multi_az" {
  description = "Enable RDS Multi-AZ deployment for high availability"
  type        = bool
  default     = false
}