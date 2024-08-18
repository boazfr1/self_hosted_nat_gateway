resource "aws_security_group" "private_instance_sg" {
  name        = "private_instance_security_group"
  description = "Security group for instance in private subnet"
  vpc_id      = aws_vpc.testing_vpc.id

  tags = {
    Name = "private_instance_sg"
  }
}

resource "aws_security_group_rule" "private_to_nat" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"  # -1 means all protocols
  security_group_id        = aws_security_group.private_instance_sg.id
  source_security_group_id = aws_security_group.nat_instance_sg.id
}

resource "aws_security_group_rule" "private_to_nat_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"  # -1 means all protocols
  security_group_id = aws_security_group.private_instance_sg.id
  cidr_blocks       = ["0.0.0.0/0"]  # Allows traffic to anywhere
}