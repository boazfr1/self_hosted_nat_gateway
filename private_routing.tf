resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.testing_vpc.id

  tags = {
    Name = "private_rt"
  }
}

resource "aws_route_table_association" "private_association" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route" "nat_route" {
  route_table_id         = aws_route_table.private_rt.id
  destination_cidr_block = "0.0.0.0/0"
  network_interface_id   = aws_network_interface.nat_instance_interface.id
}

