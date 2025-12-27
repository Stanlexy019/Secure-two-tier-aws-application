resource "aws_vpc" "terraform_vpc" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"

  tags = {
    Name = var.terraform_vpc
  }
}
