resource "aws_security_group" "nat_instance_sg" {
  name        = "nat_instance_security_group"
  description = "Security group for NAT instance"
  vpc_id      = aws_vpc.testing_vpc.id

  tags = {
    Name = "nat_instance_sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_http_from_private" {
  security_group_id = aws_security_group.nat_instance_sg.id
  cidr_ipv4         = aws_subnet.private.cidr_block
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "allow_https_from_private" {
  security_group_id = aws_security_group.nat_instance_sg.id
  cidr_ipv4         = aws_subnet.private.cidr_block
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_from_network" {
  security_group_id = aws_security_group.nat_instance_sg.id
  cidr_ipv4         = aws_subnet.private.cidr_block 
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "allow_http_to_internet" {
  security_group_id = aws_security_group.nat_instance_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_egress_rule" "allow_https_to_internet" {
  security_group_id = aws_security_group.nat_instance_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

resource "aws_vpc_security_group_egress_rule" "allow_icmp_to_anywhere" {
  security_group_id = aws_security_group.nat_instance_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = -1  # ICMP traffic uses port -1
  ip_protocol       = "icmp"
  to_port           = -1
}

resource "aws_vpc_security_group_ingress_rule" "allow_icmp_from_private" {
  security_group_id = aws_security_group.nat_instance_sg.id
  cidr_ipv4         = aws_subnet.private.cidr_block
  from_port         = -1  # ICMP traffic uses port -1
  ip_protocol       = "icmp"
  to_port           = -1
}

resource "aws_security_group_rule" "nat_to_private" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"  # -1 means all protocols
  security_group_id        = aws_security_group.nat_instance_sg.id
  source_security_group_id = aws_security_group.private_instance_sg.id
}

resource "aws_security_group_rule" "nat_to_private_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"  # -1 means all protocols
  security_group_id = aws_security_group.nat_instance_sg.id
  cidr_blocks       = [aws_vpc.testing_vpc.cidr_block]  # Allows traffic to the entire VPC
}