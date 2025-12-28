resource "aws_eip" "nat_eip" {
  domain = "vpc"

  tags = {
    Name = "${var.terraform_vpc}-nat-eip"
  }
}
