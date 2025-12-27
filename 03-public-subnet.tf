resource "aws_subnet" "public_subnet_1" {
  vpc_id            = aws_vpc.terraform_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "eu-north-1a"

  tags = {
    Name = "${var.terraform_vpc}-public-1"
  }
}


resource "aws_subnet" "public_subnet_2" {
  vpc_id            = aws_vpc.terraform_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "eu-north-1b"

  tags = {
    Name = "${var.terraform_vpc}-public-2"
  }
}
