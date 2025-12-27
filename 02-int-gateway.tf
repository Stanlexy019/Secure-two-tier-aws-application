resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.terraform_vpc.id

  tags = {
    Name = "${var.terraform_vpc}-igw"
  }
}