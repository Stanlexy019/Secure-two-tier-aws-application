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
}