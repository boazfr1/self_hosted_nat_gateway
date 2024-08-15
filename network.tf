
resource "aws_vpc" "testing_vpc" {
  tags = {
    "Name" = "testing_vpc"
  }
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
}

resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.testing_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "public_subnet"
  }
}

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.testing_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "private-subnet"
  }
}

resource "aws_network_interface" "nat_instance_interface" {
  subnet_id       = aws_subnet.public_subnet.id
  security_groups = [aws_security_group.nat_instance_sg.id]

  tags = {
    Name = "nat_instance_interface"
  }
}

resource "aws_eip" "nat_instance_eip" {
  instance                  = aws_instance.nat_instance.id
  network_interface         = aws_network_interface.nat_instance_interface.id
  associate_with_private_ip = aws_network_interface.nat_instance_interface.private_ip

  depends_on = [
    aws_instance.nat_instance
  ]
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.testing_vpc.id

  tags = {
    Name = "main-igw"
  }
}



