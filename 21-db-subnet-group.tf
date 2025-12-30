resource "aws_db_subnet_group" "db_subnet_group" {
  name = "${var.terraform_vpc}-db-subnet-group"

  subnet_ids = [
    aws_subnet.private_subnet_1.id,
    aws_subnet.private_subnet_2.id
  ]

  tags = {
    Name = "${var.terraform_vpc}-db-subnet-group"
  }
}
